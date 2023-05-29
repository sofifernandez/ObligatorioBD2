USE DBCARGAS;
SET DATEFORMAT DMY

INSERT INTO Cliente (cliNom, cliMail, cliCantCargas)
VALUES 
  ('Leonardo da Vinci', 'leonardodavinci@mail.com', 10),
  ('Pablo Picasso', 'pablopicasso@mail.com', 5),
  ('Vincent van Gogh', 'vincentvangogh@mail.com', 8),
  ('Frida Kahlo', 'fridakahlo@mail.com', 12),
  ('Salvador Dali', 'salvadordali@mail.com', 6),
  ('Michelangelo Buonarroti', 'michelangelobuonarroti@mail.com', 9),
  ('Claude Monet', 'claudemonet@mail.com', 7),
  ('Rembrandt van Rijn', 'rembrandtvanrijn@mail.com', 11),
  ('Edvard Munch', 'edvardmunch@mail.com', 3),
  ('Claude Monet', 'claudemonet2@mail.com', 4);


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
  ('DC001', 2.0, 2.5, 1.8, 5),
  ('DC002', 2.5, 3.0, 2.0, 6),
  ('DC003', 1.8, 2.0, 1.5, 3),
  ('DC004', 2.0, 2.5, 2.0, 4),
  ('DC005', 2.2, 2.8, 2.2, 5),
  ('DC006', 2.4, 2.7, 1.9, 4),
  ('DC007', 2.1, 2.6, 2.1, 6),
  ('DC008', 2.3, 2.9, 1.7, 3),
  ('DC009', 1.9, 2.2, 1.6, 4),
  ('DC010', 2.1, 2.5, 2.3, 5);

INSERT INTO Aeropuerto (codIATA, aeroNombre, aeroPais)
VALUES 
  ('AER001', 'Aeropuerto de Paris-Charles de Gaulle', 'Francia'),
  ('AER002', 'Aeropuerto de Londres Heathrow', 'Reino Unido'),
  ('AER003', 'Aeropuerto de Amsterdam Schiphol', 'Paises Bajos'),
  ('AER004', 'Aeropuerto de Francfort del Meno', 'Alemania'),
  ('AER005', 'Aeropuerto de Madrid Barajas Adolfo Suarez', 'Espania'),
  ('AER006', 'Aeropuerto de Roma Fiumicino', 'Italia'),
  ('AER007', 'Aeropuerto de Estambul Ataturk', 'Turquia'),
  ('AER008', 'Aeropuerto de Atenas-Eleftherios Venizelos', 'Grecia'),
  ('AER009', 'Aeropuerto de Lisboa-Portela', 'Portugal'),
  ('AER010', 'Aeropuerto de Dublin', 'Irlanda');


INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
VALUES 
  ('AVN001', 'DC001', '10/05/2023', 10000, 1, 'AER001', 'AER002', 'R'),
  ('AVN001', 'DC002', '12/05/2023', 8000, 1, 'AER001', 'AER003', 'R'),
  ('AVN002', 'DC003', '11/05/2023', 5000, 2, 'AER002', 'AER003', 'C'),
  ('AVN003', 'DC004', '13/05/2023', 7000, 3, 'AER003', 'AER004', 'R'),
  ('AVN004', 'DC005', '14/05/2023', 4000, 4, 'AER004', 'AER005', 'C'),
  ('AVN005', 'DC006', '15/05/2023', 3000, 5, 'AER005', 'AER006', 'R'),
  ('AVN006', 'DC007', '16/05/2023', 6000, 6, 'AER006', 'AER007', 'C'),
  ('AVN007', 'DC008', '17/05/2023', 9000, 7, 'AER007', 'AER008', 'R'),
  ('AVN008', 'DC009', '18/05/2023', 2000, 8, 'AER008', 'AER009', 'C'),
  ('AVN009', 'DC010', '19/05/2023', 5000, 9, 'AER009', 'AER010', 'R');


/*ESTOS DARIAN ERROR*/
INSERT INTO Cliente (cliNom, cliMail, cliCantCargas)
VALUES ('John Doe', 'jleonardodavinci@mail.com', 5); -- EL MAIL YA EXISTE

INSERT INTO Avion (avionID, avionMAT, avionMarca, avionModelo, avionCapacidad)
VALUES ('AV001', 'ABC123', 'Boeing', '747', 200); -- VIOLA LA CAPACIDAD MAXIMA POSIBLE

INSERT INTO Dcontainer (dContID, dContLargo, dContAncho, dcontAlto, dcontCapacidad)
VALUES ('DC001', 3.0, 2.0, 2.0, 5.0); -- EL LARGO ES MAYOR A 2.5 MTS

INSERT INTO Aeropuerto (codIATA, aeroNombre, aeroPais)
VALUES ('AER010', 'Aeropuerto de Viena-Schwechat', 'Austria'); -- ERROR DE PK Aeropuerto

INSERT INTO Carga (avionID, dContID, cargaFch, cargaKilos, cliID, aeroOrigen, aeroDestino, cargaStatus)
VALUES ('AV001', 'DC001', '01/05/2023', 1000, 100, 'AER001', 'AER002', 'R'); -- El Cliente no existe, viola la foreign key





