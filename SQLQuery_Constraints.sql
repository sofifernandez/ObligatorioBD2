

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
ALTER TABLE Dcontainer ADD CONSTRAINT CHK_dContLargo CHECK(dContLargo<=2.5);
ALTER TABLE Dcontainer ADD CONSTRAINT CHK_dContAncho CHECK(dContAncho<=3.5);
ALTER TABLE Dcontainer ADD CONSTRAINT CHK_dcontAlto CHECK(dcontAlto<=2.5);
ALTER TABLE Dcontainer ADD CONSTRAINT CHK_dcontCapacidad CHECK(dcontCapacidad<=7);

--RESTRICCIONES DE LA TABLA Aeropuerto
ALTER TABLE Aeropuerto ADD CONSTRAINT PK_Aeropuerto PRIMARY KEY (codIATA);

--RESTRICCIONES DE LA TABLA Carga
ALTER TABLE Carga ADD CONSTRAINT PK_Carga PRIMARY KEY (idCarga);
ALTER TABLE Carga ADD CONSTRAINT FK_AvionCarga FOREIGN KEY (avionID) REFERENCES Avion (avionID);
ALTER TABLE Carga ADD CONSTRAINT FK_ContainerCarga FOREIGN KEY (dContID) REFERENCES Dcontainer (dContID);
ALTER TABLE Carga ADD CONSTRAINT FK_ClienteCarga FOREIGN KEY (cliID) REFERENCES Cliente (cliID);
ALTER TABLE Carga ADD CONSTRAINT FK_AeroOrigenCarga FOREIGN KEY (aeroOrigen) REFERENCES Aeropuerto (codIATA);
ALTER TABLE Carga ADD CONSTRAINT FK_AeroDestinoCarga FOREIGN KEY (aeroDestino) REFERENCES Aeropuerto (codIATA);
ALTER TABLE Carga ADD CONSTRAINT CHK_StatusCarga CHECK (cargaStatus IN ('R', 'C', 'T', 'D', 'E')) --EN LA TABLA DICE QUE ESTE CAMPO ES CHARACTER(1)
ALTER TABLE Carga ADD CONSTRAINT UK_AvContFecha UNIQUE(avionID, dContID, cargaFch);

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




