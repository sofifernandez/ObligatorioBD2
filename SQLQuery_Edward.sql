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

			/* Chequeo que Avion no supere 150 toneladas de peso con nueva Carga */
			DECLARE @cargaKilosAvion DECIMAL(12,2)
			DECLARE @avionCapacidad DECIMAL(12,2)

			SELECT @avionCapacidad = a.avionCapacidad FROM Avion a, inserted i WHERE a.avionID = i.avionID
			SELECT @cargaKilosAvion = SUM(c.cargaKilos) + i.cargaKilos 
									  FROM Carga c, inserted i 
									  WHERE c.avionID = i.avionID 
										AND c.cargaFch = i.cargaFch 
										AND c.aeroOrigen = i.aeroOrigen 
										AND c.aeroDestino = i.aeroDestino

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
					PRINT 'ERROR: La carga la capacidad del avion'
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


/* Trigger para controlar dContID de Dcontainer (3 digitos y 3 numeros) */
IF OBJECT_ID('TRG_InsertDcontainer', 'TR') IS NOT NULL DROP TRIGGER TRG_InsertDcontainer
GO

CREATE TRIGGER TRG_InsertDcontainer
ON Dcontainer
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @dContId CHAR(6)
	DECLARE @dContIdL CHAR(3)
	DECLARE @dContIdN CHAR(3)

	SELECT @dContId = i.dContID FROM inserted i
	SELECT @dContIdL = SUBSTRING(@dContId, 1, 3)
	SELECT @dContIdN = SUBSTRING(@dContId, 4, 3)

	IF @dContIdL LIKE ('%[A-Z][a-z]') AND @dContIdN LIKE ('%[0-9]')
		BEGIN
			INSERT INTO Dcontainer (dContID, dContLargo, dContAncho, dcontAlto, dcontCapacidad)
			SELECT UPPER(i.dContID), i.dContLargo, i.dContAncho, i.dcontAlto, i.dcontCapacidad FROM inserted i
		END
	ELSE
		BEGIN
			PRINT 'ERROR: dContID no tiene el formato aceptado XXXNNN'
		END
END
GO


/* Trigger para controlar codIATA de Aeropuerto (3 digitos) */
IF OBJECT_ID('TRG_InsertAeropuerto', 'TR') IS NOT NULL DROP TRIGGER TRG_InsertAeropuerto
GO

CREATE TRIGGER TRG_InsertAeropuerto
ON Aeropuerto
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @codIATA CHAR(3)
	
	SELECT @codIATA = i.codIATA FROM inserted i

	IF @codIATA LIKE ('%[A-Z][a-z]')
		BEGIN
			INSERT INTO Aeropuerto (codIATA, aeroNombre, aeroPais)
			SELECT UPPER(i.codIATA), i.aeroNombre, i.aeroPais FROM inserted i
		END
	ELSE
		BEGIN
			PRINT 'ERROR: codIATA no tiene el formato aceptado XXX'
		END
END
GO

/* 4 f) Mostrar los datos del aeropuerto que recibió la mayor cantidad de kilos de los últimos 5 años. */

SELECT DISTINCT a.*
FROM Aeropuerto a, Carga c
WHERE a.codIATA = c.aeroDestino
	AND a.codIATA = (
						SELECT TOP 1 c1.aeroDestino
						FROM Carga c1
						WHERE YEAR(c1.cargaFch) >= YEAR(getdate())-5
						GROUP BY c1.aeroDestino, c1.cargaFch
						ORDER BY SUM(c1.cargaKilos) DESC
					)
GO


/* 5 c) Hacer una función que reciba un código de aeropuerto y retorne la cantidad de kilos 
   recibidos de carga cuando ese aeropuerto fue destino. */

IF OBJECT_ID('FN_KilosDeCargaPorAeropuerto', 'FN') IS NOT NULL DROP FUNCTION FN_KilosDeCargaPorAeropuerto
GO

CREATE FUNCTION FN_KilosDeCargaPorAeropuerto (@codAeropuerto char(3))
RETURNS DECIMAL(18,0)
AS
BEGIN
	DECLARE @kilosCargaAeropuerto DECIMAL(18,0)
	IF EXISTS (SELECT * FROM Aeropuerto a1 WHERE a1.codIATA = @codAeropuerto)
		BEGIN
			SELECT @kilosCargaAeropuerto = SUM(c.cargaKilos)
			FROM Aeropuerto a, Carga c
			WHERE a.codIATA = c.aeroDestino
			GROUP BY a.codIATA
		END
	ELSE
		BEGIN
			SET @kilosCargaAeropuerto = -1
		END

	RETURN (@kilosCargaAeropuerto)
END
GO

