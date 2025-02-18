#NIVEL 1

#EJERCICIO 2 (usando JOIN)

#Llistat dels països que estan fent compres.
#Lista dos países que estão fazendo compras.

SELECT DISTINCT c.country
FROM company c
JOIN transaction t on c.id = t.company_id;

#Des de quants països es realitzen les compres.
#Quantos países realizaram compras.

SELECT COUNT(DISTINCT c.country) as Total_Countries
FROM company c
JOIN transaction t on c.id = t.company_id;

#Identifica la companyia amb la mitjana més gran de vendes.
#Identifique a empresa com a maior média de vendas.

SELECT c.company_name, AVG(t.amount) as Average_sales
FROM company c
JOIN transaction t on c.id = t.company_id
GROUP BY c.company_name
ORDER BY Average_sales DESC
LIMIT 1;

#EJERCICIO 3(usando subqueries)

#Mostra totes les transaccions realitzades per empreses d'Alemanya.
#Mostre todas as transações feitas por empresas na Alemanha.

SELECT *
FROM transaction
WHERE company_id IN (
	SELECT id FROM company WHERE country = 'Germany');

#Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
#Liste as empresas que realizaram transações com valor superior à média de todas as transações.   

SELECT company_name
FROM company
WHERE id IN (
  SELECT DISTINCT company_id 
  FROM transaction
  WHERE amount > (SELECT AVG(amount) FROM transaction)
);

#Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
#empresas que não possuem transações cadastradas serão retiradas do sistema, forneça a lista dessas empresas.

SELECT * 
FROM company c
WHERE NOT EXISTS (
    SELECT 1 FROM transaction t 
    WHERE t.company_id = c.id
);
DELETE FROM company c
WHERE NOT EXISTS (
    SELECT 1 FROM transaction t 
    WHERE t.company_id = c.id
);

#NIVEL 2

#EJERCICIO 1

#Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.
#Identifique os cinco dias que geraram a maior receita de vendas para a empresa. Mostra a data de cada transação junto com o total de vendas.

SELECT c.company_name, DATE(t.timestamp) as Date_, SUM(t.amount) as Total_Sales
FROM transaction t
JOIN company c ON t.company_id = c.id
GROUP BY Date_, c.company_name
ORDER BY Total_Sales DESC
LIMIT 5;

#EJERCICIO 2
#Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
#Qual é a média de vendas por país? Apresenta os resultados ordenados da maior para a menor média.

SELECT c.country, AVG(t.amount) as Average_Sales
FROM company c
JOIN transaction t ON c.id = t.company_id
GROUP BY c.country
ORDER BY Average_Sales DESC;

#EJERCICIO 3
#En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute".
#Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
#Na sua empresa está sendo considerado um novo projeto de lançamento de algumas campanhas publicitárias para concorrer com a empresa “Não Instituto”.
#Para isso, solicitam a lista de todas as transações realizadas por empresas que estão localizadas no mesmo país desta empresa.

#Exiba a listagem aplicando JOIN e subqueries.
#Mostra el llistat aplicant JOIN i subconsultes.
SELECT c.company_name, t.id, c.country
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE company_id IN (SELECT id FROM company WHERE country = 'United Kingdom');

#Mostra el llistat aplicant solament subconsultes.
#Exiba a listagem aplicando apenas subqueries.

SELECT (SELECT company_name FROM company c WHERE c.id = t.company_id) AS company_name,
    t.id, (SELECT country FROM company c WHERE c.id = t.company_id) AS country
FROM transaction t
WHERE t.company_id IN (SELECT c.id FROM company c WHERE c.country = 'United Kingdom');

#NIVEL 3

#EJERCICIO 1
#Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros 
#i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.
#Apresente o nome, telefone, país, data e valor das empresas que realizaram transações com valor entre 100 e 200 euros 
#e numa destas datas: 29 de abril de 2021, 20 de julho de 2021 e 13 de março de 2022. Classifique os resultados do maior para o menor valor.

SELECT c.company_name, c.phone, c.country, DATE(t.timestamp) AS transaction_date, t.amount
FROM transaction t
JOIN company c ON c.id = t.company_id
WHERE DATE(t.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
AND t.amount BETWEEN 100 AND 200
ORDER BY t.amount DESC;

#No es correcto!
SELECT c.company_name, c.phone, c.country, DATE(t.timestamp) AS transaction_date, SUM(t.amount) AS transaction_total_amount
FROM transaction t
JOIN company c ON c.id = t.company_id
WHERE t.company_id IN (
	SELECT DISTINCT t.company_id
	FROM transaction t
	WHERE DATE(t.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
	AND t.amount BETWEEN 100 AND 200)
GROUP BY c.company_name, c.phone, c.country, DATE(t.timestamp)
ORDER BY transaction_total_amount DESC;

#EJERCICIO 2
#Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la 
#informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat 
#de les empreses on especifiquis si tenen més de 4 transaccions o menys.
#Precisamos otimizar a alocação de recursos e isso vai depender da capacidade operacional que for necessária, por isso pedem a informação 
#sobre a quantidade de transações que as empresas realizam, mas o departamento de RH é exigente e quer uma lista das empresas onde você especifica 
#se têm mais de 4 transações ou menos.

SELECT c.company_name, COUNT(1) AS total_transactions, CASE WHEN COUNT(1) > 4 THEN 'More_than_4' ELSE 'Less_than_4' END AS Classification
FROM transaction t
JOIN company c ON c.id = t.company_id
GROUP BY c.company_name
ORDER BY total_transactions DESC;

    
