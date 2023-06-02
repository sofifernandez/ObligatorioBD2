--4 --> b y d
--5 --> b y d
--6 --> b y d

USE DBCARGAS

/*
4 a) Mostrar los datos de los clientes que cargaron más kilos este año que el promedio total de kilos cargados 
por todos los clientes el año pasado
*/
SELECT cli.cliID, SUM(c.cargaKilos)
FROM Cliente cli, Carga c
WHERE cli.cliID= c.cliID
GROUP BY cli.cliID
HAVING SUM(c.cargaKilos) > (SELECT AVG(c1.cargaKilos) FROM Carga c1 WHERE YEAR(c1.cargaFch)='2022')

/*
4 b)
Del total de kilos cargados por cada avión, mostrar cuál fue el mayor valor, cuál fue el promedio y cuál fue el menor valor.
(VER): ASUMO QUE EL ESTADO 'RESERVADO' TODAVÍA NO SE CARGÓ
*/

SELECT c.avionID, MIN(c.cargaKilos) as MinKilos, MAX(c.cargaKilos) as MaxKilos, AVG(c.cargaKilos) as PromKilos
FROM Carga c
WHERE c.cargaStatus<>'R'
GROUP BY c.avionID

/*
4 c) Para cada tipo de contenedor, mostrar sus datos, la cantidad de cargas en los que fue utilizado y el total de kilos cargados, 
si algún tipo de contenedor nunca fue utilizado, también deben mostrarse sus datos.
*/

SELECT dc.dContID, dc.dContLargo, dc.dContAncho, dc.dcontAlto, dc.dcontCapacidad, COUNT(c.dContID) as Utilizado, SUM(c.cargaKilos) as kilosTotales
FROM  Dcontainer dc LEFT JOIN Carga c
ON c.dContID=dc.dContID
GROUP BY dc.dContID, dc.dContLargo, dc.dContAncho, dc.dcontAlto, dc.dcontCapacidad

/*
4 d) Mostrar los datos de los clientes que utilizaron todos los aviones disponibles para sus cargas.
*/
SELECT cli.cliID, cli.cliNom, cli.cliMail, cli.cliCantCargas, COUNT(DISTINCT c.avionID) as Aviones
FROM Cliente cli, Carga c
WHERE c.cliID=cli.cliID 
GROUP BY cli.cliID, cli.cliNom, cli.cliMail, cli.cliCantCargas
HAVING COUNT(DISTINCT c.avionID)= (SELECT COUNT(*)FROM Avion)

/*
4 e) Mostrar el identificador de la carga, la fecha y los nombres de los aeropuertos de origen y destino para todas 
las cargas del año actual que utilizan aviones con una capacidad mayor a las 100 toneladas.
*/

SELECT DISTINCT c.idCarga, c.cargaFch, a1.aeroNombre as 'Origen', a2.aeroNombre as 'Destino'
FROM Carga c, Aeropuerto a1, Aeropuerto a2, Avion av
WHERE c.aeroOrigen=a1.codIATA AND c.aeroDestino=a2.codIATA AND c.avionID=av.avionID AND av.avionCapacidad>100;


/*
5 b) 
Realizar un procedimiento almacenado que, dadas las 3 medidas de un contenedor (largo x ancho x alto) retorne en una tabla 
los datos de los contenedores que coinciden con dichas medidas, de no existir ninguno se debe retornar un mensaje.
*/

ALTER PROCEDURE sp_DimContenedores
@Largo DECIMAL(12,2),
@Ancho DECIMAL(12,2),
@Alto DECIMAL(12,2)
AS
BEGIN
 IF EXISTS
    (SELECT Dc.*
	FROM Dcontainer Dc
	WHERE Dc.dContLargo=@Largo AND Dc.dContAncho=@Ancho AND Dc.dcontAlto=@Alto)
	BEGIN
		SELECT Dc.*
		FROM Dcontainer Dc
		WHERE Dc.dContLargo=@Largo AND Dc.dContAncho=@Ancho AND Dc.dcontAlto=@Alto
	END
	ELSE
	BEGIN
        SELECT 'No se encontraron contenedores con las medidas especificadas'
    END
END

EXECUTE sp_DimContenedores 2.0,2.5,1.9



/*
5 d)
Hacer una función que, para un cliente dado, retorne la cantidad total de kilos transportados 
por dicho cliente a aeropuertos de diferente país.
*/

SELECT c.cliID,SUM(c.cargaKilos) as KilosTotales, aero.aeroPais as PaisDestino, COUNT(c.aeroDestino) as Cargas
FROM Cliente cli, Carga C, Aeropuerto aero
WHERE cli.cliID=c.cliID AND aero.codIATA=c.aeroDestino 
GROUP BY c.cliID, aero.aeroPais
ORDER BY c.cliID

CREATE FUNCTION sf_KilosClientePais(@IDCliente int)
RETURNS TABLE
AS
RETURN(
	SELECT c.cliID,SUM(c.cargaKilos) as KilosTotales, aero.aeroPais as PaisDestino, COUNT(c.aeroDestino) as Cargas
	FROM Cliente cli, Carga C, Aeropuerto aero
	WHERE cli.cliID=c.cliID AND aero.codIATA=c.aeroDestino AND cli.cliID=@IDCliente
	GROUP BY c.cliID, aero.aeroPais
	);

SELECT * FROM sf_KilosClientePais(1)


/*
6 b) Realizar un procedimiento almacenado que, dadas las 3 medidas de un contenedor (largo x ancho x alto) 
retorne en una tabla los datos de los contenedores que coinciden con dichas medidas, de no existir ninguno 
se debe retornar un mensaje.
*/

CREATE TRIGGER trg_MedidasContenedor
ON Dcontainer
AFTER UPDATE
AS
BEGIN 
	IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
		/*Si se edita el LARGO*/
	BEGIN
		IF UPDATE(dContLargo)
		INSERT INTO AuditContainer(AuditFecha,AuditHost, LargoAnterior, LargoActual) 
			SELECT getdate(),host_name(),d.dContLargo, i.dContLargo
	        FROM inserted i, deleted d
			WHERE i.dContID=d.dContID
	END
		/*Si se edita el ANCHO*/
	BEGIN
		IF UPDATE(dContAncho)
		INSERT INTO AuditContainer(AuditFecha,AuditHost, AnchoAnterior, AnchoActual) 
			SELECT getdate(),host_name(),d.dContAncho, i.dContAncho
	        FROM inserted i, deleted d
			WHERE i.dContID=d.dContID
	END
		/*Si se edita el ALTO*/
	BEGIN
		IF UPDATE(dContAlto)
		INSERT INTO AuditContainer(AuditFecha,AuditHost, AltoAnterior, AltoActual) 
			SELECT getdate(),host_name(),d.dContAncho, i.dcontAlto
	        FROM inserted i, deleted d
			WHERE i.dContID=d.dContID
	END
		/*Si se edita la CAPACIDAD */
	BEGIN
		IF UPDATE(dcontCapacidad)
		INSERT INTO AuditContainer(AuditFecha,AuditHost, CapAnterior, CapActual) 
			SELECT getdate(),host_name(),d.dcontCapacidad, i.dcontCapacidad
	        FROM inserted i, deleted d
			WHERE i.dContID=d.dContID
	END
END


SELECT * FROM Dcontainer
/*PROBAR*/
UPDATE Dcontainer SET dcontLargo=2.4 WHERE dContID='DC011'
SELECT * FROM AuditContainer


/*
6 a)
Realizar un disparador que lleve un mantenimiento de la cantidad de cargas acumuladas de un cliente, 
este disparador debe controlar tanto los ingresos de cargas como el borrado de cargas.
*/

/*NO FUNCIONA EL DELETE*/

ALTER TRIGGER trg_ActualizarCargasCliente
ON Carga
AFTER INSERT, DELETE
AS
BEGIN
	/*En caso de INSERT*/
	IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
	BEGIN
		UPDATE Cliente
		SET cliCantCargas = cliCantCargas + (SELECT COUNT(i.cliID) 
											FROM Inserted i 
											WHERE i.cliID = Cliente.cliID
											GROUP BY i.cliID)
		WHERE cliID IN (SELECT cliID
						FROM inserted)
	END

	/*En caso de DELETE*/
	IF NOT EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
	BEGIN
		UPDATE Cliente
		SET cliCantCargas = cliCantCargas - (SELECT COUNT(d.cliID) 
											FROM Deleted d 
											WHERE d.cliID = Cliente.cliID
											GROUP BY d.cliID)
		WHERE cliID IN (SELECT cliID
						FROM Deleted)
	END
END


SELECT * FROM Cliente
SELECT * FROM Carga

SELECT COUNT(c.cliID) 
FROM Carga c
GROUP BY c.cliID

UPDATE Cliente
SET cliCantCargas=0
WHERE cliID=10

/*Cliente 9 tiene 2 cargas*/
INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
VALUES 
  ('AVN003', 'DC003', '03/03/2023', 3000, 9, 'CDG', 'LHR', 'E')
/*Ahora tiene 3, yei*/
DELETE FROM Carga
WHERE avionID='AVN003' AND dContID='DC003' AND cargaFch='03/03/2023' AND cliID=9
/*Ahora tiene 2, yei*/


/*Si hacemos una múltiple...*/
/*Cliente 9 tiene 2 cargas*/
/*Cliente 10 tiene 0 cargas*/
INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
VALUES 
  ('AVN003', 'DC003', '03/03/2023', 3000, 9, 'CDG', 'LHR', 'E'),
  ('AVN004', 'DC004', '04/04/2023', 4000, 10, 'CDG', 'LHR', 'E')
/*Cliente 9 ahora tiene 3 cargas*/
/*Cliente 10 ahora tiene 1 cargas*/
DELETE FROM Carga
WHERE avionID='AVN003' AND dContID='DC003' AND cargaFch='03/03/2023' AND cliID=9
DELETE FROM Carga
WHERE avionID='AVN004' AND dContID='DC004' AND cargaFch='04/04/2023' AND cliID=10



/*
6 c) Realizar un disparador que cuando se registra una nueva carga se valide que el avión tiene capacidad suficiente para almacenarla, 
esta verificación debe tener en cuenta todas las cargas que se están haciendo en ese avión en la misma fecha.
*/

CREATE TRIGGER trg_CargaAviones
ON Carga
INSTEAD OF insert
AS
BEGIN
	INSERT INTO Carga SELECT i.avionID, i.dContID, i.cargaFch,i.cargaKilos,i.cliID,i.aeroOrigen,i.aeroDestino,i.cargaStatus
						FROM Inserted i, Avion av
						WHERE i.avionID=av.avionID AND i.avionID NOT IN 
						(
						SELECT c.avionID,c.cargaFch, av.avionCapacidad,SUM(c.cargaKilos) as CargaTotal
						FROM Inserted i, Avion av, Carga c
						WHERE c.avionID=av.avionID
						GROUP BY c.avionID,c.cargaFch, av.avionCapacidad
						HAVING SUM(c.cargaKilos)>av.avionCapacidad*1000
						)
	SELECT 'No se puede ingresar la carga para el avión ' +av.avionID + ' en la fecha ' + i.cargaFch
	FROM Inserted i, Avion av
	WHERE i.avionID=av.avionID AND i.avionID IN (
						SELECT c.avionID,c.cargaFch, av.avionCapacidad,SUM(c.cargaKilos) as CargaTotal
						FROM Carga c, Avion av
						WHERE c.avionID=av.avionID
						GROUP BY c.avionID,c.cargaFch, av.avionCapacidad
						HAVING SUM(c.cargaKilos)>av.avionCapacidad*1000
						)
END














CREATE TRIGGER trg_CargaAviones
ON Carga
INSTEAD OF insert
AS
BEGIN
	INSERT INTO Carga SELECT i.avionID, i.dContID, i.cargaFch,i.cargaKilos,i.cliID,i.aeroOrigen,i.aeroDestino,i.cargaStatus
						FROM Inserted i
						WHERE i.avionID=Carga.avionID AND i.avionID NOT IN 
						(
						SELECT c.avionID,c.cargaFch, av.avionCapacidad,SUM(c.cargaKilos) as CargaTotal
						FROM Inserted i, Avion av, Carga c
						WHERE c.avionID=av.avionID
						GROUP BY c.avionID,c.cargaFch, av.avionCapacidad
						HAVING SUM(c.cargaKilos)>av.avionCapacidad*1000
						)
	SELECT 'No se puede ingresar la carga para el avión ' +av.avionID + ' en la fecha ' + i.cargaFch
	FROM Inserted i, Avion av
	WHERE i.avionID=av.avionID AND i.avionID IN (
						SELECT c.avionID,c.cargaFch, av.avionCapacidad,SUM(c.cargaKilos) as CargaTotal
						FROM Carga c, Avion av
						WHERE c.avionID=av.avionID
						GROUP BY c.avionID,c.cargaFch, av.avionCapacidad
						HAVING SUM(c.cargaKilos)>av.avionCapacidad*1000
						)
END



