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
5 b) Realizar un procedimiento almacenado que, dadas las 3 medidas de un contenedor (largo x ancho x alto) retorne en una tabla 
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

execute sp_DimContenedores 2.0,2.5,1.9

/*
Hacer una función que, para un cliente dado, retorne la cantidad total de kilos transportados 
por dicho cliente a aeropuertos de diferente país.
*/

SELECT SUM(c.cargaKilos)
FROM Cliente cli, Carga C
WHERE cli.cliID=c.cliID
GROUP BY c.cliID




