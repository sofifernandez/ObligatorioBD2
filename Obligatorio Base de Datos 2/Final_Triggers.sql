USE DBCARGAS
SET DATEFORMAT DMY

/* 6a - 6c */
IF OBJECT_ID('TRG_InsertCarga', 'TR') IS NOT NULL DROP TRIGGER TRG_InsertCarga
GO

CREATE TRIGGER TRG_InsertCarga
ON Carga
INSTEAD OF INSERT
AS
BEGIN
	/* Chequeo que no exista registro con iguales avionID, dContID y cargaFch */
	IF NOT EXISTS (SELECT * FROM Carga c, inserted i WHERE c.idCarga = i.idCarga AND c.dContID = i.dContID AND c.cargaFch = i.cargaFch)
		BEGIN

			/* Chequeo que Avion no supere toneladas de peso que soporta con la nueva Carga */
			DECLARE @cargaKilosAvion DECIMAL(12,2)
			DECLARE @avionCapacidad DECIMAL(12,2)

			SELECT @avionCapacidad = a.avionCapacidad * 1000 FROM Avion a, inserted i WHERE a.avionID = i.avionID
			SELECT @cargaKilosAvion = SUM(c.cargaKilos) + i.cargaKilos 
									  FROM Carga c, inserted i 
									  WHERE c.avionID = i.avionID 
										AND c.cargaFch = i.cargaFch 
										AND c.aeroOrigen = i.aeroOrigen 
										AND c.aeroDestino = i.aeroDestino
									  GROUP BY i.cargaKilos

			IF (@cargaKilosAvion <= @avionCapacidad)
				BEGIN
					/* Carga de datos en caso de que todo este ok */
					INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
					SELECT i.avionID, i.dContID, i.cargaFch, i.cargaKilos, i.cliID, i.aeroOrigen, i.aeroDestino, i.cargaStatus FROM inserted i
			
					/* Actualizo cliCantCargas de Cliente */
					UPDATE Cliente
					SET cliCantCargas = cliCantCargas + (SELECT COUNT(i.cliID) 
														FROM Inserted i 
														WHERE i.cliID = Cliente.cliID
														GROUP BY i.cliID)
					WHERE cliID IN (SELECT cliID
									FROM inserted)
				END
			ELSE
				BEGIN
					PRINT 'ERROR: La carga supera la capacidad del avion'
				END
		END
END
GO

IF OBJECT_ID('TRG_DeleteCarga', 'TR') IS NOT NULL DROP TRIGGER TRG_DeleteCarga
GO

CREATE TRIGGER TRG_DeleteCarga
ON Carga
AFTER DELETE
AS
BEGIN
	UPDATE Cliente
	SET cliCantCargas = cliCantCargas - (SELECT COUNT(d.cliID) 
										FROM Deleted d 
										WHERE d.cliID = Cliente.cliID
										GROUP BY d.cliID)
	WHERE cliID IN (SELECT cliID
					FROM Deleted)
END
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

ALTER TRIGGER TRG_InsertCargaCheckCapacidad
ON Carga
INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON
	/* Chequeo que Avion no supere toneladas de peso que soporta con la nueva Carga */
	DECLARE @nuevaCargaKilosAvion DECIMAL(12,2)
	DECLARE @kilosActualesAvion DECIMAL(12,2)
	DECLARE @avionCapacidad DECIMAL(12,2)

	SELECT @avionCapacidad = a.avionCapacidad * 1000 FROM Avion a, inserted i WHERE a.avionID = i.avionID

	SELECT @kilosActualesAvion = SUM(c2.cargaKilos) FROM Carga c2, inserted i2 WHERE c2.avionID = i2.avionID;

	SELECT @nuevaCargaKilosAvion = i.cargaKilos + @kilosActualesAvion FROM inserted i;
	
	IF (@nuevaCargaKilosAvion <= @avionCapacidad)
		BEGIN
			/* Carga de datos en caso de que todo este ok */
			INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
			SELECT i.avionID, i.dContID, i.cargaFch, i.cargaKilos, i.cliID, i.aeroOrigen, i.aeroDestino, i.cargaStatus FROM inserted i
		END
	ELSE
		BEGIN
			PRINT 'ERROR: La carga supera la capacidad del avion'
		END
END
GO

/* PRUEBAS 6c */
/* CARGA SIN ERROR */
INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
VALUES 
  ('AVN001', 'DCC009', '18/01/2023', 1500, 1, 'CDG', 'LHR', 'R');

/* CARGA CON ERROR */
INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
VALUES 
  ('AVN001', 'DCC009', '19/01/2023', 150000, 1, 'CDG', 'LHR', 'R');
