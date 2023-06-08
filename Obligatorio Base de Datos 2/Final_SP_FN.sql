/*
5 a)
Escribir un procedimiento almacenado que reciba como parámetros un rango de fecha y retorne también por parámetros el identificador de avión que cargó 
más kilos en dicho rango de fechas y el nombre del cliente que cargó más kilos en dicho rango (si hay más de uno, mostrar el primero).
*/
USE DBCARGAS
SET DATEFORMAT DMY

IF OBJECT_ID('sp_MaxKilosEntreFechas', 'SP') IS NOT NULL DROP PROCEDURE sp_MaxKilosEntreFechas
GO

CREATE PROCEDURE sp_MaxKilosEntreFechas
@Desde DATE,
@Hasta DATE,
@AvionID CHAR(10) OUTPUT,
@ClienteNombre VARCHAR(30) OUTPUT
AS
BEGIN
	SET @AvionID = (SELECT TOP 1 av.avionID
					FROM Avion av, Carga c
					WHERE av.avionID=c.avionID AND c.cargaFch BETWEEN @Desde AND @Hasta
					GROUP BY av.avionID
					HAVING SUM(c.cargaKilos)= (SELECT TOP 1 SUM(c.cargakilos) as Total
												FROM Carga c
												WHERE c.cargaFch BETWEEN @Desde AND @Hasta
												GROUP BY c.avionID
												ORDER BY SUM(c.cargakilos) DESC))
	SET @ClienteNombre = (SELECT cli.cliNom
							FROM Cliente cli
							WHERE cli.cliID = (SELECT TOP 1 cli.cliID
												FROM Cliente cli, Carga c
												WHERE cli.cliID=c.cliID AND c.cargaFch BETWEEN @Desde AND @Hasta
												GROUP BY cli.cliID
												HAVING SUM(c.cargaKilos)= (SELECT TOP 1 SUM(c.cargakilos) as Total
																			FROM Carga c
																			WHERE c.cargaFch BETWEEN @Desde AND @Hasta
																			GROUP BY c.cliID
																			ORDER BY SUM(c.cargakilos) DESC)))
END
GO

DECLARE @Avion CHAR(10),@Cliente VARCHAR(30)
EXECUTE sp_MaxKilosEntreFechas '01/01/2022', '31/12/2022', @Avion OUTPUT,@Cliente OUTPUT
PRINT @Avion
PRINT @Cliente

/*
5 b) 
Realizar un procedimiento almacenado que, dadas las 3 medidas de un contenedor (largo x ancho x alto) retorne en una tabla 
los datos de los contenedores que coinciden con dichas medidas, de no existir ninguno se debe retornar un mensaje.
*/

IF OBJECT_ID('sp_DimContenedores', 'SP') IS NOT NULL DROP PROCEDURE sp_DimContenedores
GO

CREATE PROCEDURE sp_DimContenedores
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
GO

-- Ejecucion donde no hay contenedores
EXECUTE sp_DimContenedores 2.0, 2.5, 1.9

-- Ejecucion donde si hay contenedores
EXECUTE sp_DimContenedores 2.0, 2.5, 1.8


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
				AND a.codIATA = @codAeropuerto
			GROUP BY a.codIATA
		END
	ELSE
		BEGIN
			SET @kilosCargaAeropuerto = -1
		END

	RETURN (@kilosCargaAeropuerto)
END
GO

DECLARE @kilosCargaAero DECIMAL(18,0)
SELECT @kilosCargaAero = dbo.FN_KilosDeCargaPorAeropuerto('ATH') 
PRINT @kilosCargaAero

/*
5 d)
Hacer una función que, para un cliente dado, retorne la cantidad total de kilos transportados 
por dicho cliente a aeropuertos de diferente país.
*/

IF OBJECT_ID('sf_KilosClientePais', 'FN') IS NOT NULL DROP FUNCTION sf_KilosClientePais
GO

/* Aclaracion: dado que nos surgio una duda sobre la interpretacion de lo solicitado, se platean dos funciones para distintas situaciones */
/* - sf_KilosClientePais la cual retorna los Kg totales transportados a un pais, agrupando por pais de destino. Es decir, que de existir 
   mas de un aeropuerto dentro de un mismo pais, se considerara como cargas del mismo pais. */
/* - sf_KilosClienteAeroPais la cual retorna los Kg totales transportados a un pais, agrupando por aeropuerto. Es decir, que de existir
   mas de un aeropuerto dentro de un mismo pais, se considerara como otra tupla a retornar. */

CREATE FUNCTION sf_KilosClientePais(@IDCliente int)
RETURNS TABLE
AS
RETURN(
	SELECT c.cliID,SUM(c.cargaKilos) as KilosTotales, aero.aeroPais as PaisDestino, COUNT(c.aeroDestino) as Cargas, COUNT(DISTINCT aero.codIATA) NumAeropuertos
	FROM Cliente cli, Carga C, Aeropuerto aero
	WHERE cli.cliID=c.cliID AND aero.codIATA=c.aeroDestino AND cli.cliID=@IDCliente
	GROUP BY c.cliID, aero.aeroPais
	);
GO

-- Ejemplo de ejecucion
SELECT * FROM sf_KilosClientePais(1)

IF OBJECT_ID('sf_KilosClienteAeroPais', 'FN') IS NOT NULL DROP FUNCTION sf_KilosClienteAeroPais
GO

CREATE FUNCTION sf_KilosClienteAeroPais(@IDCliente int)
RETURNS TABLE
AS
RETURN(
	SELECT c.cliID,SUM(c.cargaKilos) as KilosTotales, aero.codIATA as PaisDestino, COUNT(c.aeroDestino) as Cargas, COUNT(DISTINCT aero.codIATA) NumAeropuertos
	FROM Cliente cli, Carga C, Aeropuerto aero
	WHERE cli.cliID=c.cliID AND aero.codIATA=c.aeroDestino AND cli.cliID=@IDCliente
	GROUP BY c.cliID, aero.codIATA
	);
GO

-- Ejemplo de ejecucion
SELECT * FROM sf_KilosClienteAeroPais(1)


