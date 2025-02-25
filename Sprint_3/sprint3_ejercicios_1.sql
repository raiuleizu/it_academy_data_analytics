#NIVEL 1

#EJERCICIO 1

#La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials 
#sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar de manera única cada targeta 
#i establir una relació adequada amb les altres dues taules ("transaction" i "company"). 
#Després de crear la taula serà necessari que ingressis la informació del document denominat 
#"dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15) PRIMARY KEY,
    iban VARCHAR(100),
    pan VARCHAR (100),
    pin VARCHAR (4),
    cvv VARCHAR(3),
    expiring_date VARCHAR (10)
);

#Adding a foreign key to the table 'transaction' so it can reference the table 'credit_card'
ALTER TABLE transaction 
ADD CONSTRAINT fk_transaction_credit_card 
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

#EJERCICIO 2
#El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. 
#La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999. 
#Recorda mostrar que el canvi es va realitzar.

#checked all the information for the id 'CcU-2938' first
SELECT *
FROM credit_card
WHERE id = 'CcU-2938';

UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';

#EJERCICIO 3
#En la taula "transaction" ingressa un nou usuari amb la següent informació:

#add the id: 'b-9999' to the column 'id' in the table 'company', and also add the id: 'Cc-9999' to the table 
#credit_card, so they can reference the table 'transaction'
INSERT INTO company (id) VALUES ('b-9999');

INSERT INTO credit_card (id) VALUES ('CcU-9999');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

#EJERCICIO 4
#Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. 
#Recorda mostrar el canvi realitzat.

ALTER TABLE credit_card
DROP COLUMN pan;

SHOW COLUMNS FROM credit_card;

#NIVEL 2

#EJERCICIO 1
#Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.

#deleting the id
DELETE FROM transaction 
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

#checking to see if it was deleted
SELECT *
FROM transaction t
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

#EJERCICIO 2
#La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
#S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
#Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
#Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
#Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.
CREATE VIEW VistaMarketing AS
SELECT company_name, phone, country,
ROUND(AVG(COALESCE(amount,0)),2) AS 'Average_Sales'
FROM company
JOIN transaction ON company.id = transaction.company_id
GROUP BY company_name, country, phone
ORDER BY Average_per_company DESC;

#EJERCICIO 3
#Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
SELECT *
FROM vistamarketing
WHERE country = 'Germany';

#NIVEL 3

#EJERCICIO 1
#La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar 
#modificacions en la base de dades, però no recorda com les va realitzar. Et demana que l'ajudis a deixar els 
#comandos executats per a obtenir el següent diagrama:

#1 Download and exam the files that creates and populates the table 'data_user', to check how it's being created.

#2 There is one error in the script for the creation of the table 'data_user', the foreign key is being created wrong.
#The diagram on the exercise shows the correct relationship between the tables 'transaction' and 'data_user', 
#the foreign key should be the column 'user_id' in the table 'transaction' and the primary key should be the 
#column 'id' in the table 'user'.

CREATE INDEX idx_user_id ON transaction(user_id);
 
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255)
    );

#4 Find 'user_id' values in the table 'transaction' that don't exist in 'id' in the table 'user', and insert them.

SELECT user_id FROM transaction WHERE user_id NOT IN (SELECT id FROM user);

INSERT INTO user (id) 
SELECT DISTINCT user_id FROM transaction 
WHERE user_id NOT IN (SELECT id FROM user);

#5 Then we can alter the table 'transaction' and add a foreign key to the column 'user_id' and relate it to the column 'id'
#in the 'user' table.

ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_user FOREIGN KEY (user_id) REFERENCES user(id);

# Modelo:  
## Tabla 'user':  
#- Cambiar el nombre de la tabla 'user' a 'data_user'.  
ALTER TABLE user RENAME TO data_user;

#- Cambiar el nombre de la columna 'email' a 'personal_email'.
ALTER TABLE data_user CHANGE email personal_email VARCHAR(150);

## Tabla 'company':  
#- Eliminar la columna 'website' de la tabla 'company'.  
ALTER TABLE company DROP COLUMN website;

## Tabla 'credit_card':  
#- Cambiar 'cvv' a tipo INT.
#- Cambiar 'expiring_date' a tipo VARCHAR(20).  
#- Agregar una columna llamada 'fecha_actual' de tipo DATE.
ALTER TABLE credit_card
MODIFY cvv INT,
MODIFY expiring_date VARCHAR(20),
ADD COLUMN fecha_actual DATE;

#EJERCICIO 2
#L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:

#ID de la transacció
#Nom de l'usuari/ària
#Cognom de l'usuari/ària
#IBAN de la targeta de crèdit usada.
#Nom de la companyia de la transacció realitzada.
#Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.

#Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.

CREATE VIEW InformeTecnico AS
SELECT t.id as Transactions, 
	   du.name as User_Name, 
       du.surname as User_Last_Name, 
       cc.iban as Iban, 
       c.company_name as Company
FROM data_user du
JOIN transaction t ON du.id = t.user_id
JOIN credit_card cc ON t.credit_card_id = cc.id
JOIN company c ON t.company_id = c.id
ORDER BY t.id DESC;