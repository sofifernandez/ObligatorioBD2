USE DBCARGAS
SET DATEFORMAT DMY

/*
6 a)
Realizar un disparador que lleve un mantenimiento de la cantidad de cargas acumuladas de un cliente, 
este disparador debe controlar tanto los ingresos de cargas como el borrado de cargas.
*/

IF OBJECT_ID('TRG_UpdateCarga', 'TR') IS NOT NULL DROP TRIGGER TRG_UpdateCarga
GO

CREATE TRIGGER TRG_UpdateCarga
ON Carga
AFTER INSERT, DELETE
AS
BEGIN
	/*En caso de INSERT*/
	IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
	BEGIN
		UPDATE Cliente
		SET cliCantCargas = cliCantCargas + 1
		WHERE cliID IN (SELECT cliID
						FROM inserted)
	END

	/*En caso de DELETE*/
	IF NOT EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
	BEGIN
		UPDATE Cliente
		SET cliCantCargas = cliCantCargas - 1
		WHERE cliID IN (SELECT cliID
						FROM deleted)
	END
END
GO

select * from carga

INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
VALUES 
  ('AVN001', 'DCC001', '10/01/2023', 1000, 1, 'CDG', 'LHR', 'R');
  ('AVN001', 'DCC002', '12/02/2023', 100, 1, 'CDG', 'AMS', 'C'),
  ('AVN002', 'DCC003', '11/03/2023', 100, 1, 'LHR', 'AMS', 'T'),
  ('AVN003', 'DCC004', '13/04/2023', 100, 1, 'AMS', 'FRA', 'D'),
  ('AVN004', 'DCC005', '14/05/2022', 100, 1, 'FRA', 'MAD', 'E'),
  ('AVN005', 'DCC006', '15/06/2022', 100, 1, 'MAD', 'FCO', 'E'),
  ('AVN006', 'DCC007', '16/07/2022', 100, 1, 'FCO', 'IST', 'R'),
  ('AVN007', 'DCC008', '17/08/2021', 100, 1, 'IST', 'ATH', 'C'),
  ('AVN008', 'DCC009', '18/09/2021', 100, 1, 'ATH', 'LIS', 'T'),
  ('AVN009', 'DCC010', '19/10/2021', 100, 1, 'LIS', 'IST', 'T');

SELECT * FROM Avion
SELECT * FROM Carga
SELECT * FROM Cliente where cliID = 1

IF OBJECT_ID('trg_MedidasContenedor', 'TR') IS NOT NULL DROP TRIGGER trg_MedidasContenedor
GO

/*
6 b) Hacer un disparador que, ante la modificación de cualquier medida de un contenedor, lleve un registro detallado en la tabla AuditContainer 
(ver estructura de la tabla en el anexo del presente obligatorio).
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



/* 6 c) Realizar un disparador que cuando se registra una nueva carga se valide que el avión 
	tiene capacidad suficiente para almacenarla, esta verificación debe tener en cuenta 
	todas las cargas que se están haciendo en ese avión en la misma fecha */
IF OBJECT_ID('TRG_InsertCargaCheckCapacidad', 'TR') IS NOT NULL DROP TRIGGER TRG_InsertCargaCheckCapacidad
GO

CREATE TRIGGER TRG_InsertCargaCheckCapacidad
ON Carga
INSTEAD OF insert
AS
BEGIN
	INSERT INTO Carga	
	SELECT i.avionID, i.dContID, i.cargaFch,i.cargaKilos,i.cliID,i.aeroOrigen,i.aeroDestino,i.cargaStatus
						FROM Inserted i, carga c
						WHERE i.cargaFch=c.cargaFch and  c.avionID=i.avionID AND i.avionID in (SELECT c.avionID
																						FROM  Avion av, Carga c
																						WHERE c.avionID=av.avionID AND c.cargaFch=i.cargaFch AND c.avionID=i.avionID 
																						GROUP BY c.avionID,c.cargaFch, av.avionCapacidad
																						HAVING av.avionCapacidad*1000 > SUM(c.cargaKilos) + i.cargaKilos) 
	
	

	SELECT 'No se puede ingresar la carga para el avión ' +i.avionID + ' en la fecha ' + CAST(i.cargaFch AS VARCHAR) 
	FROM Inserted i, Carga c
	WHERE i.cargaFch=c.cargaFch and  c.avionID=i.avionID AND i.avionID in (SELECT c.avionID
																						FROM  Avion av, Carga c
																						WHERE c.avionID=av.avionID AND c.cargaFch=i.cargaFch AND c.avionID=i.avionID 
																						GROUP BY c.avionID,c.cargaFch, av.avionCapacidad
																						HAVING av.avionCapacidad*1000 < SUM(c.cargaKilos) + i.cargaKilos) 
	
END

/* PRUEBAS 6c */
/* CARGA SIN ERROR */
INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
VALUES 
  ('AVN001', 'DCC009', '19/01/2023', 1500, 1, 'CDG', 'LHR', 'R');

/* CARGA CON ERROR */
INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
VALUES 
  ('AVN001', 'DCC009', '19/01/2023', 150000, 1, 'CDG', 'LHR', 'R');