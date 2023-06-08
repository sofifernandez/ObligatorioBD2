CREATE DATABASE DBCARGAS
GO
USE DBCARGAS
GO
/* Creacion de tablas SIN restricciones */
CREATE TABLE Cliente(cliID int identity not null,
                     cliNom varchar(30) not null,
					 cliMail varchar(50),
					 cliCantCargas int)
GO
CREATE TABLE Avion(avionID char(10) not null,
                   avionMAT varchar(20) not null,
				   avionMarca varchar(30) not null,
				   avionModelo varchar(30) not null,
				   avionCapacidad decimal)
GO
CREATE TABLE Dcontainer(dContID char(6) not null,
                       	dContLargo decimal,
						dContAncho decimal,
						dcontAlto decimal,
						dcontCapacidad decimal)
GO
CREATE TABLE Aeropuerto(codIATA char(3) not null,
                        aeroNombre varchar(30) not null,
						aeroPais varchar(30) not null)
GO
CREATE TABLE Carga(idCarga int identity not null,
                   avionID char(10) not null,
				   dContID char(6) not null,
				   cargaFch date,
				   cargaKilos decimal,
				   cliID int,
				   aeroOrigen char(3),
				   aeroDestino char(3),
				   cargaStatus char(1))
GO
CREATE TABLE AuditContainer(AuditID int identity not null,
                            AuditFecha datetime,
							AuditHost varchar(30),
                       	    LargoAnterior decimal,
						    AnchoAnterior decimal,
						    AltoAnterior decimal,
						    CapAnterior decimal,
							LargoActual decimal,
						    AnchoActual decimal,
						    AltoActual decimal,
						    CapActual decimal)
GO							

/*
--------------------------------------------------------------------------------------------------------------------
---------------------------------RESTRICCIONES----------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
*/

use DBCARGAS


ALTER TABLE Carga ALTER COLUMN dContID CHAR(6);

ALTER TABLE Dcontainer ALTER COLUMN dContLargo DECIMAL(12,2);
ALTER TABLE Dcontainer ALTER COLUMN dcontAlto DECIMAL(12,2);
ALTER TABLE Dcontainer ALTER COLUMN dcontAncho DECIMAL(12,2);

ALTER TABLE Avion ALTER COLUMN avionCapacidad DECIMAL(12,2)

ALTER TABLE AuditContainer ALTER COLUMN LargoAnterior DECIMAL(12,2)
ALTER TABLE AuditContainer ALTER COLUMN AnchoAnterior DECIMAL(12,2)
ALTER TABLE AuditContainer ALTER COLUMN AltoAnterior DECIMAL(12,2)
ALTER TABLE AuditContainer ALTER COLUMN CapAnterior DECIMAL(12,2)
ALTER TABLE AuditContainer ALTER COLUMN LargoActual DECIMAL(12,2)
ALTER TABLE AuditContainer ALTER COLUMN AnchoActual DECIMAL(12,2)
ALTER TABLE AuditContainer ALTER COLUMN AltoActual DECIMAL(12,2)
ALTER TABLE AuditContainer ALTER COLUMN CapActual DECIMAL(12,2)



--RESTRICCIONES DE LA TABLA Cliente
ALTER TABLE Cliente ADD CONSTRAINT PK_Cliente PRIMARY KEY (cliID);
ALTER TABLE Cliente ADD CONSTRAINT UK_MailCliente UNIQUE(cliMail);

--RESTRICCIONES DE LA TABLA Avion
ALTER TABLE Avion ADD CONSTRAINT PK_Avion PRIMARY KEY (avionID);
ALTER TABLE Avion ADD CONSTRAINT CHK_avionCapacidad CHECK(avionCapacidad<=150);

--RESTRICCIONES DE LA TABLA Dcontainer
ALTER TABLE Dcontainer ADD CONSTRAINT PK_Dcontainer PRIMARY KEY (dContID);
ALTER TABLE Dcontainer ADD CONSTRAINT CHK_ContID CHECK (dContID LIKE '[A-Za-z][A-Za-z][A-Za-z][0-9][0-9][0-9]'); --'^[A-Za-z]{3}[0-9]{3}$'
ALTER TABLE Dcontainer ADD CONSTRAINT CHK_dContLargo CHECK(dContLargo<=2.5);
ALTER TABLE Dcontainer ADD CONSTRAINT CHK_dContAncho CHECK(dContAncho<=3.5);
ALTER TABLE Dcontainer ADD CONSTRAINT CHK_dcontAlto CHECK(dcontAlto<=2.5);
ALTER TABLE Dcontainer ADD CONSTRAINT CHK_dcontCapacidad CHECK(dcontCapacidad<=7);

--RESTRICCIONES DE LA TABLA Aeropuerto
ALTER TABLE Aeropuerto ADD CONSTRAINT PK_Aeropuerto PRIMARY KEY (codIATA);
ALTER TABLE Aeropuerto ADD CONSTRAINT CHK_codIATA CHECK (codIATA LIKE '[A-Za-z][A-Za-z][A-Za-z]');

--RESTRICCIONES DE LA TABLA Carga
ALTER TABLE Carga ADD CONSTRAINT PK_Carga PRIMARY KEY (idCarga);
ALTER TABLE Carga ADD CONSTRAINT FK_AvionCarga FOREIGN KEY (avionID) REFERENCES Avion (avionID);
ALTER TABLE Carga ADD CONSTRAINT FK_ContainerCarga FOREIGN KEY (dContID) REFERENCES Dcontainer (dContID);
ALTER TABLE Carga ADD CONSTRAINT FK_ClienteCarga FOREIGN KEY (cliID) REFERENCES Cliente (cliID);
ALTER TABLE Carga ADD CONSTRAINT FK_AeroOrigenCarga FOREIGN KEY (aeroOrigen) REFERENCES Aeropuerto (codIATA);
ALTER TABLE Carga ADD CONSTRAINT FK_AeroDestinoCarga FOREIGN KEY (aeroDestino) REFERENCES Aeropuerto (codIATA);
ALTER TABLE Carga ADD CONSTRAINT CHK_StatusCarga CHECK (cargaStatus IN ('R', 'C', 'T', 'D', 'E')) --EN LA TABLA DICE QUE ESTE CAMPO ES CHAR(1)
ALTER TABLE Carga ADD CONSTRAINT UK_AvContFecha UNIQUE(avionID, dContID, cargaFch);

--RESTRICCIONES DE LA TABLA AuditContainer
ALTER TABLE AuditContainer ADD CONSTRAINT PK_AuditContainer PRIMARY KEY (AuditID);

/*
--------------------------------------------------------------------------------------------------------------------
---------------------------------INDICES----------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
*/
CREATE INDEX IDX_AvionCarga ON Carga(avionID);
CREATE INDEX IDX_ContainerCarga ON Carga(dContID);
CREATE INDEX IDX_ClienteCarga ON Carga(cliID);
CREATE INDEX IDX_AeroOrigenCarga ON Carga(aeroOrigen);
CREATE INDEX IDX_AeroDestinoCarga ON Carga(aeroDestino);





/*
--------------------------------------------------------------------------------------------------------------------
---------------------------------DATOS DE PRUEBA----------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
*/

----------------------------------------------------------------------------------------------------------------------------
USE DBCARGAS;
SET DATEFORMAT DMY


INSERT INTO Cliente (cliNom, cliMail, cliCantCargas)
VALUES 
  ('Leonardo da Vinci', 'leonardodavinci@mail.com', 3),
  ('Pablo Picasso', 'pablopicasso@mail.com', 2),
  ('Vincent van Gogh', 'vincentvangogh@mail.com', 2),
  ('Frida Kahlo', 'fridakahlo@mail.com', 1),
  ('Salvador Dali', 'salvadordali@mail.com', 1),
  ('Michelangelo Buonarroti', 'michelangelobuonarroti@mail.com', 1),
  ('Claude Monet', 'claudemonet@mail.com', 2),
  ('Rembrandt van Rijn', 'rembrandtvanrijn@mail.com', 2),
  ('Edvard Munch', 'edvardmunch@mail.com', 2),
  ('Claude Monet', 'claudemonet2@mail.com', 0);


INSERT INTO Avion (avionID, avionMAT, avionMarca, avionModelo, avionCapacidad)
VALUES 
  ('AVN001', 'MAT001', 'Boeing', '747', 150),
  ('AVN002', 'MAT002', 'Airbus', 'A380', 120),
  ('AVN003', 'MAT003', 'Embraer', 'E190', 50),
  ('AVN004', 'MAT004', 'Bombardier', 'CRJ900', 70),
  ('AVN005', 'MAT005', 'Cessna', 'Citation X', 10),
  ('AVN006', 'MAT006', 'Airbus', 'A320', 80),
  ('AVN007', 'MAT007', 'Boeing', '777', 130),
  ('AVN008', 'MAT008', 'Embraer', 'E175', 45),
  ('AVN009', 'MAT009', 'Cessna', 'Citation Sovereign', 15),
  ('AVN010', 'MAT010', 'Bombardier', 'Global Express', 90);


INSERT INTO Dcontainer (dContID, dContLargo, dContAncho, dcontAlto, dcontCapacidad)
VALUES 
  ('DCC001', 2.0, 2.5, 1.8, 5),
  ('DCC002', 2.5, 3.5, 2.5, 7),
  ('DCC003', 1.8, 2.0, 1.5, 3),
  ('DCC004', 2.0, 2.5, 2.0, 4),
  ('DCC005', 2.2, 2.8, 2.2, 5),
  ('DCC006', 2.4, 2.7, 1.9, 4),
  ('DCC007', 2.1, 2.6, 2.1, 6),
  ('DCC008', 2.3, 2.9, 1.7, 3),
  ('DCC009', 1.9, 2.2, 1.6, 4),
  ('DCC010', 2.1, 2.5, 2.3, 5);

INSERT INTO Dcontainer (dContID, dContLargo, dContAncho, dcontAlto, dcontCapacidad)
VALUES ('DCC011', 2.0, 2.5, 1.8, 4) --contenedor que nunca se usó (para la query 4c)

INSERT INTO Aeropuerto (codIATA, aeroNombre, aeroPais)
VALUES 
  ('CDG', 'Paris-Charles de Gaulle', 'Francia'),
  ('LHR', 'Londres Heathrow', 'Reino Unido'),
  ('AMS', 'Amsterdam Schiphol', 'Paises Bajos'),
  ('FRA', 'Frankfurt am Main', 'Alemania'),
  ('MAD', 'Madrid Barajas Adolfo Suarez', 'Espania'),
  ('FCO', 'Roma Fiumicino', 'Italia'),
  ('IST', 'Estambul Ataturk', 'Turquia'),
  ('ATH', 'Atenas-Eleftherios Venizelos', 'Grecia'),
  ('LIS', 'Lisboa-Portela', 'Portugal'),
  ('DUB', 'Dublin-Aerfort Bhaile Atha Cli', 'Irlanda');

  --Otro aeropuerto que comparta país para el procedimiento almacenado 5d
INSERT INTO Aeropuerto (codIATA, aeroNombre, aeroPais)
VALUES ('LGW', 'Londres-Gatwick', 'Reino Unido');


INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
VALUES 
  ('AVN001', 'DCC001', '10/01/2023', 10000, 1, 'CDG', 'LHR', 'R'),
  ('AVN001', 'DCC002', '12/02/2023', 8000, 1, 'CDG', 'AMS', 'C'),
  ('AVN002', 'DCC003', '11/03/2023', 5000, 2, 'LHR', 'AMS', 'T'),
  ('AVN003', 'DCC004', '13/04/2023', 7000, 3, 'AMS', 'FRA', 'D'),
  ('AVN004', 'DCC005', '14/05/2022', 4000, 4, 'FRA', 'MAD', 'E'),
  ('AVN005', 'DCC006', '15/06/2022', 3000, 5, 'MAD', 'FCO', 'E'),
  ('AVN006', 'DCC007', '16/07/2022', 6000, 6, 'FCO', 'IST', 'R'),
  ('AVN007', 'DCC008', '17/08/2021', 9000, 7, 'IST', 'ATH', 'C'),
  ('AVN008', 'DCC009', '18/09/2021', 2000, 8, 'ATH', 'LIS', 'T'),
  ('AVN009', 'DCC010', '19/10/2021', 5000, 9, 'LIS', 'IST', 'T'),
  
  ('AVN001', 'DCC008', '11/08/2020', 8000, 7, 'IST', 'DUB', 'D'),
  ('AVN002', 'DCC009', '12/09/2020', 1000, 8, 'ATH', 'IST', 'R'),
  ('AVN003', 'DCC010', '13/10/2019', 4000, 9, 'LIS', 'CDG', 'R'),
  ('AVN004', 'DCC004', '14/08/2019', 8000, 1, 'IST', 'LHR', 'C'),
  ('AVN005', 'DCC005', '15/09/2019', 1000, 2, 'ATH', 'AMS', 'C'),
  ('AVN006', 'DCC006', '16/10/2018', 6000, 3, 'LIS', 'FRA', 'D')
  ;


-- Para que el cliente 1 haya usado todos los aviones (para la query 4d)
INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
VALUES ('AVN001', 'DCC008', '12/01/2023', 7000, 1, 'FRA', 'MAD', 'D'),
  ('AVN002', 'DCC009', '13/02/2023', 800, 1, 'ATH', 'LIS', 'R'),
  ('AVN003', 'DCC010', '14/03/2022', 3000, 1, 'FRA', 'MAD', 'R'),
  ('AVN004', 'DCC004', '15/04/2022', 7000, 1, 'IST', 'LHR', 'C'),
  ('AVN005', 'DCC005', '16/05/2021', 900, 1, 'ATH', 'AMS', 'C'),
  ('AVN006', 'DCC006', '17/06/2020', 5000, 1, 'ATH', 'LIS', 'D'),
  ('AVN007', 'DCC008', '18/07/2020', 7000, 1, 'FRA', 'MAD', 'D'),
  ('AVN008', 'DCC009', '19/08/2019', 2000, 1, 'ATH', 'IST', 'R'),
  ('AVN009', 'DCC010', '20/09/2018', 4000, 1, 'IST', 'LHR', 'R'),
  ('AVN010', 'DCC004', '21/10/2018', 8000, 1, 'FRA', 'MAD', 'C');

 --Para el procedimiento almacenado 5d
  INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
VALUES   ('AVN009', 'DCC001', '19/10/2018', 4000, 1, 'LIS', 'LGW', 'E')



/* ESTOS QUE GENERAN ERROR */
/* COMENTADO PARA QUE SCRIPT SE PUEDA EJECUTAR SIN PROBLEMAS */
/*
INSERT INTO Cliente (cliNom, cliMail, cliCantCargas)
VALUES ('John Doe', 'leonardodavinci@mail.com', 5); -- EL MAIL YA EXISTE

INSERT INTO Avion (avionID, avionMAT, avionMarca, avionModelo, avionCapacidad)
VALUES ('AV001', 'ABC123', 'Boeing', '747', 200); -- VIOLA LA CAPACIDAD MAXIMA POSIBLE

INSERT INTO Dcontainer (dContID, dContLargo, dContAncho, dcontAlto, dcontCapacidad)
VALUES ('DC011', 3.0, 2.0, 2.0, 5.0); -- EL LARGO ES MAYOR A 2.5 MTS

INSERT INTO Aeropuerto (codIATA, aeroNombre, aeroPais)
VALUES ('DUB', 'Aeropuerto de Viena-Schwechat', 'Austria'); -- ERROR DE PK Aeropuerto

INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
VALUES ('AV001', 'DC001', '01/05/2023', 1000, 100, 'CDG', 'LHR', 'R'); -- El Avion no existe, viola la foreign key
*/
