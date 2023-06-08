USE DBCARGAS
SET DATEFORMAT DMY

/*
4 a) Mostrar los datos de los clientes que cargaron más kilos este año que el promedio total de kilos cargados 
por todos los clientes el año pasado
*/
SELECT cli.cliID, cli.cliNom, cli.cliMail, cli.cliCantCargas, SUM(c.cargaKilos)
FROM Cliente cli, Carga c
WHERE cli.cliID= c.cliID
GROUP BY cli.cliID, cli.cliNom, cli.cliMail, cli.cliCantCargas
HAVING SUM(c.cargaKilos) > (SELECT AVG(c1.cargaKilos) FROM Carga c1 WHERE YEAR(c1.cargaFch)=YEAR(getdate())-1)

/*
4 b)
Del total de kilos cargados por cada avión, mostrar cuál fue el mayor valor, cuál fue el promedio y cuál fue el menor valor.
*/

SELECT c.avionID, MIN(c.cargaKilos) as MinKilos, MAX(c.cargaKilos) as MaxKilos, AVG(c.cargaKilos) as PromKilos
FROM Carga c
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
WHERE c.aeroOrigen=a1.codIATA AND c.aeroDestino=a2.codIATA AND c.avionID=av.avionID AND av.avionCapacidad>100 AND YEAR(c.cargaFch)=YEAR(getdate());

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

