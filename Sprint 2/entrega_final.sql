/*
Sprint2 SQL

Autor: Moreno Tatti

Contenido:
- Nivel 1
- Nivel 2
- Nivel 3

Para ejecutar algunos LOAD DATA LOCAL INFILE
puede ser necesario adaptar las rutas de los CSV.
*/


use transactions;

-- EXERCICI 2

-- Llistat dels països que estan generant vendes.

SELECT DISTINCT           -- uso el DISTINCT por no repetir Paises
    c.country AS País
FROM
    company AS c
        INNER JOIN
    transaction AS t ON c.id = t.company_id
WHERE
    t.declined = 0;
    


  
-- Des de quants països es generen les vendes.

SELECT 
    COUNT(DISTINCT c.country) AS Numero_Paises_que_generan_ventas
FROM
    company AS c
        INNER JOIN
    transaction AS t ON c.id = t.company_id
WHERE
    t.declined = 0;
    

-- Identifica la companyia amb la mitjana més gran de vendes.

SELECT 
	c.company_name AS Empresa,
    ROUND(AVG(t.amount), 2) AS Media_de_ventas
FROM
    company AS c
        INNER JOIN
    transaction AS t ON c.id = t.company_id
GROUP BY c.id, c.company_name
ORDER BY AVG(t.amount) DESC
LIMIT 1;

-- EXERCICI 3


-- Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT 
    *
FROM
    transaction AS t
WHERE
    EXISTS( SELECT 
            1
        FROM
            company AS c
        WHERE
            c.id = t.company_id
                AND c.country = 'Germany');
            


-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT 
    c.company_name AS Empresa
FROM
    company AS c
WHERE
    EXISTS( SELECT 
            1
        FROM
            transaction AS t
        WHERE
            t.company_id = c.id
                AND t.amount > (SELECT 
                    AVG(t2.amount)
                FROM
                    transaction AS t2));



-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT 
    c.id, c.company_name
FROM
    company AS c
WHERE
    NOT EXISTS( SELECT 
            t.company_id
        FROM
            transaction AS t
        WHERE
            t.company_id = c.id);
            
-- EXERCICI 4

-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit.
-- La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company").
-- Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit".
-- Recorda mostrar el diagrama i realitzar una breu descripció d'aquest

CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(10) PRIMARY KEY NOT NULL,
    iban VARCHAR(50),
    pan VARCHAR(20),
    pin VARCHAR(4),
    cvv VARCHAR(10),
    expiring_date VARCHAR(10)
);

SET SQL_SAFE_UPDATES = 0; -- desactivamos temporalmente el safe mode porque es una modificacion masiva de datos importado

UPDATE credit_card          -- con esto update convertimos el valor de expiring_date de texto a fecha
SET 
    expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y');  

SET SQL_SAFE_UPDATES = 1; -- reactivamos otra vez el safe mode

ALTER TABLE credit_card   -- ahora cambiamos el tipo de datos
MODIFY expiring_date DATE;

ALTER TABLE transaction   -- creamos la relacion entre tablas mediante la FK en la tabla transaction
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

-- EXERCICI 5

-- El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938.
-- La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

SELECT 
    *
FROM
    credit_card AS cc
WHERE
    cc.id = 'CcU-2938';
    
UPDATE credit_card 
SET 
    iban = 'TR323456312213576817699999'
WHERE
    id = 'CcU-2938';

-- EXERCICI 6

-- En la taula "transaction" ingressa una nova transacció 

INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date)    -- tenemos que inventar datos ficticio ya que el credit_card_id no existe
VALUES ('CcU-9999', 'IT59832015454448157328', '455 63488 32288 611', '1241', '562', '2027-09-21');

INSERT INTO company (id, company_name, phone, email, country, website)  -- tenemos que inventar una empresa ficticia ya que el company_id no existe
VALUES ('b-9999', 'Moreno_Fiction s.p.a', '06 21 17 69 78', 'fiction@gmail.com', 'Italy', 'https://fiction.com');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999','b-9999','9999', '829.999', '-117.999','111.11', '0');

SELECT 
    *
FROM
    transaction
WHERE
    id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- EXERCICI 7
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.

ALTER TABLE credit_card
DROP COLUMN pan;

SELECT 
    *
FROM
    credit_card;

-- EXERCICI 8
/* Descarrega els arxius CSV que trobaràs a l'apartat de recursos:

american_users.csv
european_users.csv
companies.csv
credit_cards.csv
transactions.csv
Estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes */

-- creamos una nueva base de datos
CREATE DATABASE IF NOT EXISTS users_companies;
USE users_companies;

-- creamos la nueva tabla dim_users
CREATE TABLE IF NOT EXISTS dim_users (    
    user_id INT PRIMARY KEY,
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(15),
    email VARCHAR(50),
    birth_date VARCHAR(15),
    country VARCHAR(30),
    city VARCHAR(50),
    postal_code VARCHAR(10),
    address VARCHAR(100),
    signup_date DATE,
    user_segment VARCHAR(30),
    income_band VARCHAR(15),
    region VARCHAR(15)
);

-- creamos la tabla companies
CREATE TABLE IF NOT EXISTS companies (
    company_id VARCHAR(20) PRIMARY KEY,
    company_name VARCHAR(50),
    phone VARCHAR(30),
    email VARCHAR(100),
    country VARCHAR(30),
    website VARCHAR(100),
    merchant_category VARCHAR(15),
    merchant_price_position VARCHAR(15)
);

-- creamos la tabla credit_cards
CREATE TABLE IF NOT EXISTS credit_cards (
    id VARCHAR(20) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(35),
    pan VARCHAR(25),
    pin VARCHAR(10),
    cvv VARCHAR(3),
    track_1 VARCHAR(100),
    track_2 VARCHAR(100),
    expiring_date VARCHAR(10),
    card_type VARCHAR(25),
    card_renewal_flag BOOL
);

-- creamos la tabla de transactions
CREATE TABLE IF NOT EXISTS transactions (
    id VARCHAR(40) PRIMARY KEY,
    card_id VARCHAR(20),
    business_id VARCHAR(20),
    timestamp TIMESTAMP,
    amount DECIMAL(10, 2),
    declined BOOL,
    product_ids VARCHAR(100),
    user_id INT,
    lat FLOAT,
    longitude FLOAT,
    discount_amount DECIMAL(10, 2),
    tax_amount DECIMAL(10, 2),
    shipping_amount DECIMAL(10, 2),
    channel VARCHAR(25),
    campaign_id VARCHAR(30),
    device_type VARCHAR(10),
    is_international BOOL,
    decline_reason VARCHAR(50),
    distance_km DECIMAL(10, 2)
);

-- cargamos los datos del archivo csv
SET GLOBAL local_infile = 1;  -- habilitamos el LOAD DATA LOCAL para cargar el archivo

LOAD DATA LOCAL
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__american_users.csv"
INTO TABLE dim_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS
(user_id, name, surname, phone, email, birth_date, country, city, postal_code, address, signup_date, user_segment, income_band)
SET region = 'America';

LOAD DATA LOCAL
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__european_users.csv"
INTO TABLE dim_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS
(user_id, name, surname, phone, email, birth_date, country, city, postal_code, address, signup_date, user_segment, income_band)
SET region = 'Europe';

LOAD DATA LOCAL
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__credit_cards.csv"
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- convertimos algunos tipo de data en la tabla dim_users
SET SQL_SAFE_UPDATES = 0;
UPDATE dim_users
SET birth_date = STR_TO_DATE(birth_date, '%M %e, %Y');

ALTER TABLE dim_users
MODIFY birth_date DATE;

-- en la tabla credit_cards
UPDATE credit_cards
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y');
SET SQL_SAFE_UPDATES = 1;
ALTER TABLE credit_cards
MODIFY expiring_date DATE;

-- relaciones entre tablas
-- creamos las FK en la tabla transactions que va a ser la tabla de hecho

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_users
FOREIGN KEY (user_id)
REFERENCES dim_users(user_id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_cards
FOREIGN KEY (card_id)
REFERENCES credit_cards(id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_companies
FOREIGN KEY (business_id)
REFERENCES companies(company_id);

-- EXERCICI 9
-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.

SELECT 
    du.name,
    du.surname,
    (SELECT 
            COUNT(*)
        FROM
            transactions t
        WHERE
            t.user_id = du.user_id) AS num_transacciones
FROM
    dim_users AS du
WHERE
    EXISTS( SELECT 
            t.user_id
        FROM
            transactions AS t
        WHERE
            t.user_id = du.user_id
        GROUP BY t.user_id
        HAVING COUNT(*) > 80);
        
-- EXERCICI 10
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT 
    cc.iban, ROUND(AVG(t.amount), 2) AS media_de_importe
FROM
    transactions AS t
        INNER JOIN
    credit_cards AS cc ON t.card_id = cc.id
        INNER JOIN
    companies AS co ON t.business_id = co.company_id
WHERE
    co.company_name = 'Donec Ltd'
        AND cc.card_type IN ('credit' , 'premium_credit')
        AND t.declined = 0
GROUP BY cc.iban
ORDER BY media_de_importe DESC;

-- NIVEL 2 EXERCICI 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
-- Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT 
    DATE(t.timestamp) AS fecha,
    ROUND(SUM(t.amount), 2) AS total_ventas
FROM
    transactions AS t
WHERE
    t.declined = 0
GROUP BY fecha
ORDER BY total_ventas DESC
LIMIT 5;

-- NIVEL 2 EXERCICI 2
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros
-- i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. Ordena els resultats de major a menor quantitat.

SELECT 
    co.company_name AS nombre_empresa,
    co.phone AS telefono_de_contacto,
    co.country AS pais,
    DATE(t.timestamp) AS fecha,
    ROUND(t.amount, 2) AS importe_transaccion
FROM
    companies AS co
        INNER JOIN
    transactions AS t ON co.company_id = t.business_id
WHERE
    t.declined = 0
        AND t.amount BETWEEN 350 AND 400
        AND DATE(t.timestamp) IN ('2015-04-29' , '2018-07-20', '2024-03-13')
ORDER BY importe_transaccion DESC;

-- NIVEL 2 EXERCICI 3
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi,
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses,
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen igual o més de 400 transaccions o menys.


SELECT 
    co.company_name AS nombre_empresa,
    COUNT(t.business_id) AS num_transacciones,
    CASE
        WHEN COUNT(t.business_id) >= 400 THEN '400 o más transacciones'
        ELSE 'menos de 400 transacciones'
    END AS capacidad_empresa
FROM
    companies AS co
        INNER JOIN
    transactions AS t ON co.company_id = t.business_id
GROUP BY co.company_id
ORDER BY num_transacciones DESC;

-- NIVEL 2 EXERCICI 4 
-- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.

select *                   -- verificamos el registro antes de borrarlo
from transactions
WHERE
    id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
    
DELETE FROM transactions   -- eliminamos el registro
WHERE
    id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
    
select *                   -- verificamos que se haya borrado correctamente
from transactions
WHERE
    id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- NIVEL 2 EXERCICI 5
/*La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives.
S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions.
Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. Telèfon de contacte.
País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.*/

CREATE VIEW vista_marketing AS      -- creamos la vista
    SELECT 
        co.company_name AS nombre_empresa,
        co.phone AS telefono_de_contacto,
        co.country AS pais,
        ROUND(AVG(t.amount), 2) AS media_de_compra
    FROM
        companies AS co
            INNER JOIN
        transactions AS t ON co.company_id = t.business_id
    GROUP BY co.company_id, co.company_name, co.phone, co.country;
    
-- presentamos la lista ordenada
SELECT 
    *
FROM
    vista_marketing
ORDER BY media_de_compra DESC;

-- NIVEL 3 EXERCICI 1
/*Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les tres últimes transaccions
 han estat declinades aleshores és inactiu, si almenys una no és rebutjada aleshores és actiu. Partint d’aquesta taula respon:

👉 Quantes targetes estan actives? */

CREATE TABLE IF NOT EXISTS credit_card_status AS

WITH last_3 AS (              -- utilizo una CTE y ROW_NUMBER por calcular el numero de transacciones por tarjeta ordenadas cronologicamente
SELECT t.card_id,
	   t.declined,
	   ROW_NUMBER() OVER(PARTITION BY t.card_id ORDER BY t.timestamp DESC) as transacciones
FROM transactions as t
)
SELECT 
    l3.card_id,
    CASE
        WHEN SUM(l3.declined) = 3 THEN FALSE
        ELSE TRUE
    END AS is_active
FROM
    last_3 AS l3
WHERE
    transacciones <= 3
GROUP BY l3.card_id;

-- calculamos el numero de tarjetas activas
SELECT 
    COUNT(*) AS numero_tarjetas_activas
FROM
    credit_card_status AS ccs
WHERE
    ccs.is_active = TRUE;


-- NIVEL 3 EXERCICI 2
/* Crea una taula amb la qual puguem unir les dades de l'arxiu de products.csv amb la base de dades creada (ja que fins ara no podíem fer-ho),
 tenint en compte que des de transaction tens product_ids. Genera la següent consulta:
👉 Necessitem conèixer el nombre de vegades que s'ha venut cada producte. */

-- creamos la tabla products
CREATE TABLE IF NOT EXISTS products (
id INT PRIMARY KEY,
product_name VARCHAR(70),
price VARCHAR(25),
colour CHAR(7),
weight DECIMAL(6, 2),
warehouse_id VARCHAR(15),
category VARCHAR(30),
brand VARCHAR(70),
cost VARCHAR(25),
launch_date DATE
);

-- cargamos el archivo csv 
LOAD DATA LOCAL
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__products.csv"   -- Ruta utilizada durante la realización de la práctica.Puede ser necesario modificarla según la ubicación de los CSV en cada equipo.
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- convertimos algunos datos

SET SQL_SAFE_UPDATES = 0;

UPDATE products 
SET 
    price = REPLACE(price, '$', ''),
    cost = REPLACE(cost, '$', '')
WHERE
    price LIKE '$%' OR cost LIKE '$%';
    
SET SQL_SAFE_UPDATES = 1;    

ALTER TABLE products
MODIFY price DECIMAL(10, 2);

ALTER TABLE products
MODIFY cost DECIMAL(10, 2);

/* para unir la tabla productos con la tabla de hecho(transaction) de la BBDD tenemos que crear una tabla intermedia
ya que sería imposible crear una FK directa en cuanto tenemos una relación de N:M */

CREATE TABLE IF NOT EXISTS transaction_products (
transaction_id VARCHAR(100),
product_id INT,
PRIMARY KEY (transaction_id, product_id),
FOREIGN KEY (transaction_id) REFERENCES transactions (id),
FOREIGN KEY (product_id) REFERENCES products (id)
);

/* insertamos los datos en la tabla intermedia mediante una JSON TABLE que convierte los product_ids de la tabla transaction
en un array y los ordena en la columna product_id */

INSERT INTO transaction_products (transaction_id, product_id)  
SELECT
    t.id,
    jt.product_id
FROM transactions t
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(t.product_ids, ',', '","'), '"]'),    -- acá convertimos product_ids en un array
    '$[*]'                                                     -- acá le decimos de recorrer todos los elementos del array
    COLUMNS (                                                  -- con COLUMNS creamos un registro por cada elemento en la columna product_id
        product_id INT PATH '$'
    )
) jt;


-- respondiendo a la consulta

SELECT 
    p.product_name, COUNT(tp.product_id) AS unidad_vendidas
FROM
    products AS p
        LEFT JOIN
    transaction_products AS tp ON p.id = tp.product_id
GROUP BY p.id , p.product_name
ORDER BY unidad_vendidas DESC;