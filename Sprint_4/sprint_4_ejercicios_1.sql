#NIVEL 1

#Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella 
#que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:
#Download the CSV files, study them and design a database with a star schema that contains 
#at least 4 tables from which you can perform the following queries:

CREATE DATABASE IF NOT EXISTS sprint_4;

#Estructura de las tablas.
CREATE TABLE IF NOT EXISTS company (
	id VARCHAR(20) PRIMARY KEY,
	company_name VARCHAR(100),
	phone VARCHAR(15),
	email VARCHAR(100),
	country VARCHAR(100),
	website VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS user (
        id VARCHAR (10) PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(50),
        city VARCHAR(50),
        postal_code VARCHAR(100),
        address VARCHAR(255)
    );

CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR (15) PRIMARY KEY,
    user_id VARCHAR (10),
    iban VARCHAR (100),
    pan VARCHAR (100),
    pin VARCHAR (4),
    cvv VARCHAR (3),
    track_1 VARCHAR (255),
    track_2 VARCHAR (255),
    expiring_date VARCHAR (10)
);

CREATE TABLE IF NOT EXISTS transaction (
	id VARCHAR (255) PRIMARY KEY,
    card_id VARCHAR (15),
    company_id VARCHAR (20),
    timestamp TIMESTAMP,
    amount DECIMAL (10, 2),
    declined BOOLEAN,
    product_ids VARCHAR (20),
    user_id VARCHAR (10),
    lat FLOAT,
    longitude FLOAT
);

#Agregando las informaciones en las tablas:
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE "C:/Users/Victor/Desktop/Especializacion_Datos/Sprint_4/companies.csv"
    INTO TABLE company
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES;

LOAD DATA LOCAL INFILE "C:/Users/Victor/Desktop/Especializacion_Datos/Sprint_4/credit_cards.csv"
    INTO TABLE credit_card
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES;
    
LOAD DATA LOCAL INFILE "C:/Users/Victor/Desktop/Especializacion_Datos/Sprint_4/transactions.csv"
    INTO TABLE transaction
    FIELDS TERMINATED BY ';' -- Cambiado para semicolon
    #ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES;
    
LOAD DATA LOCAL INFILE "C:/Users/Victor/Desktop/Especializacion_Datos/Sprint_4/users_usa.csv"
    INTO TABLE user -- Usuarios de USA
    FIELDS TERMINATED BY ',' -- Indica el separador de campo
    ENCLOSED BY '"' -- Cómo se delimitan las cadenas de texto
    LINES TERMINATED BY '\r\n' -- Carriage Return (CR) i Line Feed (LF)
    IGNORE 1 LINES; -- Ignora la primera línea que contiene el nombre de la columna.

LOAD DATA LOCAL INFILE "C:/Users/Victor/Desktop/Especializacion_Datos/Sprint_4/users_ca.csv"
    INTO TABLE user -- Usuarios de Canada
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES;
    
LOAD DATA LOCAL INFILE "C:/Users/Victor/Desktop/Especializacion_Datos/Sprint_4/users_uk.csv"
    INTO TABLE user -- Usuarios de UK
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES;

#Comprobando los datos
SELECT * FROM company;
SELECT * FROM credit_card;
SELECT * FROM user;
SELECT * FROM transaction;

#Creando las conecciones de las tablas
ALTER TABLE transaction
ADD CONSTRAINT fk_company_id FOREIGN KEY (company_id) REFERENCES company(id),
ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES user(id),
ADD CONSTRAINT fk_card_id FOREIGN KEY (card_id) REFERENCES credit_card(id);

#EJERCICIO 1
#Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
#Perform a subquery that shows all users with more than 30 transactions using at least 2 tables.

SELECT u.name, u.surname, (SELECT COUNT(t.id) FROM transaction t WHERE u.id = t.user_id) AS number_of_transactions
FROM user u
WHERE (SELECT COUNT(t.id) 
		FROM transaction t 
        WHERE u.id = t.user_id) > 30;

#EJERCICIO 2
#Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
#Show the average amount per IBAN of credit cards in the company Donec Ltd, uses at least 2 tables.
#Fazer correcao desse exercicio, com declined 0!!

SELECT cc.iban, c.company_name, AVG(t.amount) as Avg_Amount
FROM transaction t
JOIN credit_card cc ON t.card_id = cc.id
JOIN company c ON t.company_id = c.id
WHERE c.company_name = 'Donec Ltd' AND t.declined = 0
GROUP BY cc.iban, c.company_name;

#NIVEL 2 -

#Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes 
#tres transaccions van ser declinades i genera la següent consulta:
#Create a new table that reflects the status of credit cards based on whether the last 
#three transactions were declined and generate the following query:

#creando la tabla
CREATE TABLE card_status (
			card_id VARCHAR (15) PRIMARY KEY,
            status VARCHAR (15)
			);

#agregando los datos
INSERT INTO card_status (card_id, status)
SELECT card_id, CASE WHEN SUM(declined) = 3 THEN 'Blocked' ELSE 'Active' END AS card_status
FROM (
		SELECT card_id, declined, ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY timestamp DESC) as rn
		FROM transaction
        ) AS sub
WHERE rn <= 3
GROUP BY card_id;

#creando la coneccion con la tabla transaction
ALTER TABLE transaction
ADD CONSTRAINT fk_card_status FOREIGN KEY (card_id) REFERENCES card_status(card_id);


#EJERCICIO 1

#Quantes targetes estan actives?
#How many cards are active?

SELECT COUNT(status) as active_cards
FROM card_status
WHERE status = 'Active';

#NIVEL 3

#Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, 
#tenint en compte que des de transaction tens product_ids. Genera la següent consulta:
#Create a table with which we can join the data from the new products.csv file with the created database, 
#taking into account that from transaction you have product_ids.

#creando la tabla
CREATE TABLE IF NOT EXISTS product (
	id VARCHAR (10) PRIMARY KEY,
	product_name VARCHAR (100),
	price VARCHAR (100),
	color VARCHAR (100),
	weight VARCHAR (10),
	warehouse_id VARCHAR (255)
);

#agregando los datos
LOAD DATA LOCAL INFILE "C:/Users/Victor/Desktop/Especializacion_Datos/Sprint_4/products.csv"
    INTO TABLE product
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES;

#comprobando los datos    
SELECT * FROM product;

#creé una tabla de unión entre 'transacción' y 'producto'
CREATE TABLE IF NOT EXISTS transaction_product (
	transaction_id VARCHAR (255),
    product_id VARCHAR (10),
    PRIMARY KEY (transaction_id, product_id)
);

SELECT id, product_ids FROM transaction;


#organizando la información e insertandola en la tabla transaction_product
INSERT INTO transaction_product (transaction_id, product_id)
WITH RECURSIVE split AS (
    -- Anchor part: sacando el primero product ID y lo que resta de la string
    SELECT
        id,
        TRIM(SUBSTRING_INDEX(product_ids, ',', 1)) AS product_id,     -- extracts the first product ID from the comma-separated list, TRIM eliminates extra spaces, etc
        CASE WHEN INSTR(product_ids, ',') > 0                         -- returns the position where the comma first appears, checks whether a comma exists in the string. If it does, that means there is more than one product ID to process.
            THEN SUBSTRING(product_ids, INSTR(product_ids, ',') + 1)
            ELSE NULL 
        END AS rest
    FROM transaction
	# WHERE declined = 0
    UNION ALL

-- Recursive part: continua cortando el resto de la string 
    SELECT
        id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS product_id,
        CASE WHEN INSTR(rest, ',') > 0 
            THEN SUBSTRING(rest, INSTR(rest, ',') + 1)
            ELSE NULL 
        END AS rest
    FROM split
    WHERE rest IS NOT NULL
)
SELECT id, product_id
FROM split;

#comprobando los datos
SELECT * FROM transaction_product;

#creando las conecciones con las tablas product and transaction
ALTER TABLE transaction_product
ADD CONSTRAINT fk_transaction FOREIGN KEY (transaction_id) REFERENCES transaction (id),
ADD CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES product (id);

#EJERCICIO 1

#Genera la següent consulta:
#Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
#We need to know the number of times each product has been sold.

SELECT p.product_name, COUNT(tp.product_id) as products_sold
FROM transaction_product tp
JOIN product p ON tp.product_id = p.id
GROUP BY p.product_name;
