DROP DATABASE IF EXISTS magazin;
CREATE DATABASE magazin;
USE magazin;

-- verificare
SELECT DATABASE();
-- Clienti tabelul parinte pentru comenzi
CREATE TABLE Clienti (
	id_client INT AUTO_INCREMENT PRIMARY KEY,
	nume VARCHAR(100) NOT NULL,
	oras VARCHAR(50),
	varsta INT CHECK (varsta >= 0)
) ENGINE=InnoDB;

-- Produse tabelul parinte pentru DetaliiComanda
CREATE TABLE Produse (
	id_produs INT AUTO_INCREMENT PRIMARY KEY,
	nume VARCHAR(120) NOT NULL,
	pret DECIMAL(10,2) NOT NULL CHECK (pret >= 0),
	stoc INT NOT NULL CHECK (stoc >= 0)
)ENGINE=InnoDB;

-- Comenzi FK spre clienti 
CREATE TABLE Comenzi (
id_comanda INT AUTO_INCREMENT PRIMARY KEY,
id_client INT NOT NULL,
data_comanda DATE NOT NULL,
CONSTRAINT fk_comenzi_clienti
	FOREIGN KEY (id_client) REFERENCES Clienti(id_client)
)ENGINE=InnoDB;

-- DETALII COMANDA FK SPRE COMENZI SI PRODUSE - PK COMPUS!
CREATE TABLE DetaliiComanda(
id_comanda INT NOT NULL,
id_produs INT NOT NULL,
cantitate INT NOT NULL CHECK (cantitate > 0),
PRIMARY KEY (id_comanda, id_produs),
CONSTRAINT fk_detalii_comanda
	FOREIGN KEY (id_comanda) REFERENCES Comenzi(id_comanda),
CONSTRAINT fk_detalii_produs
		FOREIGN KEY (id_produs) REFERENCES Produse (id_produs)
) ENGINE=InnoDB;

-- verificare tabele
SHOW TABLES;
DESCRIBE Clienti;
DESCRIBE Produse;
DESCRIBE Comenzi;
DESCRIBE DetaliiComanda;

-- date test 
INSERT INTO Clienti (nume, oras, varsta) VALUES
	('Maria Popa', 'Bucuresti', 28),
	('Andrei Ionescu', 'Cluj', 34),
	('Elena Dumitru', 'Bucuresti', 22),
    ('Ion Popescu', 'bucuresti', 45),
    ('George Stan', 'Timisoara', 30),
    ('Ioana Radu', 'Constanta', 30),
    ('Paula Mihai', 'Cluj', 	38);
    
INSERT INTO Produse (nume, pret, stoc) VALUES
	('Telefon Samsung', 1200.50, 10),
	('Mouse Logitech', 	  80.00, 25),
	('Laptop Lenevo',   3400.99,  5),
    ('Casti Sony',       150.00, 12),
    ('Cablu USB',         25.20, 50),
    ('Monitor Dell 24',  920.00,  8);
    
-- antetul comenzii
INSERT INTO Comenzi (id_client, data_comanda)
VALUES (3, '2025-10-10');

-- IA ID-UL GENERAT
SET @id_comanda := LAST_INSERT_ID();

-- VERIFICARE
SELECT @id_comanda;

-- liniile comenzi 
INSERT INTO DetaliiComanda (id_comanda, id_produs, cantitate) VALUES
(@id_comanda, 2, 1), -- Mouse x1
(@id_comanda, 1, 1); -- Telefon x1    

-- id-ul folosit
SELECT @id_comanda AS id_comanda_curenta;

-- Verificare
SELECT * FROM Clienti;
SELECT * FROM Produse;
SELECT * FROM Comenzi ORDER BY data_comanda DESC;
SELECT * FROM DetaliiComanda ORDER BY id_comanda, id_produs;

SELECT * FROM Clienti 
WHERE oras = "Bucuresti";
SELECT *
FROM Clienti
ORDER BY varsta DESC
LIMIT 5;

-- cati clienti sunt in fiecare oras
SELECT oras, COUNT(*) AS nr_clienti
FROM Clienti 
GROUP BY oras;

-- Pretul mediu al produselor
SELECT AVG(pret) AS pret_mediu
FROM produse;

-- Suma totala a valorilor stocului (pretxstoc)
SELECT SUM(pret * stoc) AS total_valoare_stoc
FROM Produse;

-- Comenzi per client(inclusiv cei cu 0 comenzi)
SELECT
  cl.id_client,
  cl.nume,
  COUNT(c.id_comanda) AS nr_comenzi
FROM Clienti cl
LEFT JOIN Comenzi c
  ON c.id_client = cl.id_client
GROUP BY cl.id_client, cl.nume
ORDER BY nr_comenzi DESC, cl.nume
LIMIT 0, 1000;

-- afiseaza toate comenzile cu numele clientului si data
SELECT c.id_comanda, cl.nume, c.data_comanda
FROM Comenzi c
JOIN Clienti cl ON cl.id_client = c.id_client
ORDER BY c.data_comanda DESC, c.id_comanda;    

-- Produse comandate de Ion Popescu
SELECT DISTINCT p.nume
FROM Produse p
JOIN DetaliiComanda d ON d.id_produs = p.id_produs
JOIN Comenzi c 		  ON c.id_comanda = d.id_comanda
JOIN Clienti cl 	  ON cl.id_client = c.id_client
WHERE cl.nume = 'Ion Popescu'
ORDER BY p.nume;

-- Valoarea totala a fiecarei comenzi
SELECT d.id_comanda,
	SUM(p.pret * d.cantitate) AS total
FROM DetaliiComanda d
JOIN Produse p ON p.id_produs = d.id_produs
GROUP BY d.id_comanda
ORDER BY d.id_comanda;

-- produsele care nu au fost comandate niciodata
SELECT p.*
FROM Produse p
WHERE NOT EXISTS (
	SELECT 1
    FROM DetaliiComanda d
    WHERE d.id_produs = p.id_produs
)
ORDER BY p.nume;

-- Clientul cu varsta maxima 
SELECT *
FROM Clienti
WHERE Varsta = (SELECT MAX(varsta) FROM Clienti);

-- produse cu pret > media
SELECT *
FROM Produse
WHERE pret > (SELECT AVG(pret) FROM Produse)
ORDER BY pret DESC;

-- clienti cu cel putin o comanda in ultimile 30 de zile 
SELECT DISTINCT cl.*
FROM Clienti cl
JOIN COMENZI C ON c.id_client = cl.id_client
WHERE c.data_comanda >= CURRENT_DATE - INTERVAL 30 DAY;

-- total pe comanda
CREATE OR REPLACE VIEW V_TotalComenzi AS
SELECT d.id_comanda,
		SUM(p.pret * d.cantitate) AS total
FROM DetaliiComanda d
JOIN Produse p ON p.id_produs = d.id_produs
GROUP BY d.id_comanda;

-- INDEX pr Produse.nume
CREATE INDEX idx_produse_nume ON Produse(nume);

-- TRIGGER care scade stocul dupa inserarea in detalii 
DELIMITER $$

CREATE TRIGGER trg_update_stoc
AFTER INSERT ON DetaliiComanda
FOR EACH ROW
BEGIN 
	UPDATE Produse
    SET stoc = stoc - NEW.cantitate
    WHERE id_produs = NEW.id_produs;
END $$

-- Total cheltuit de un client 
DELIMITER $$

CREATE PROCEDURE TotalCheltuit(IN p_client_id INT)
BEGIN
	SELECT SUM(p.pret * d.cantitate) AS total
    FROM Comenzi c
    JOIN DetaliiComanda d ON d.id_comanda = c.id_comanda
    JOIN Produse p 			ON p.id_produs = d.id_produs
    WHERE c.id_client = p_client_id;
END$$
DELIMITER ; 
        
    
 


        
    


