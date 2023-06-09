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
VALUES ('DCC011', 2.0, 2.5, 1.8, 4) --contenedor que nunca se us� (para la query 4c)

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

  --Otro aeropuerto que comparta pa�s para el procedimiento almacenado 5d
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

/*ESTOS DARIAN ERROR*/
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






