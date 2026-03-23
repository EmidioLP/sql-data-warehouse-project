/*
==========================================================================================
Objetivo:
	Contém uma magnitude de Scripts para realização da análise exploratória dos dados
	gerados durante todo o processo de criação da Data Warehouse. Geram métricas úteis
	para serem apresentadas e utilizadas no negócio.
==========================================================================================
*/

-- Explorar todos os objetos da Base de Dados
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Explorar todas as colunas da Base de Dados
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers' -- Para verificar especificamente a tabela dos consumidores

-- Explorando todos os países dos consumidores
SELECT DISTINCT country FROM gold.dim_customers

-- Explorando todas as categorias 
SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products
ORDER BY 1,2,3

-- Encontre as datas do primeiro e ultimo pedido
-- Quantos anos de vendas estão disponíveis
SELECT 
MIN(order_date) first_order_date,
MAX(order_date) last_order_date,
DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years
FROM gold.fact_sales

-- Encontre o mais novo e o mais velho consumidor
SELECT
MIN(birthdate) AS oldest_birthdate,
DATEDIFF(year, MIN(birthdate), GETDATE()) as oldest_age,
MAX(birthdate) AS youngest_birthdate,
DATEDIFF(year, MAX(birthdate), GETDATE()) as youngest_age
FROM gold.dim_customers

-- Encontre o número total de vendas
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales

-- Encontre quantos itens foram vendidos
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales

-- Encontre a média de preços de venda
SELECT AVG(price) AS avg_price FROM gold.fact_sales

-- Encontre o número total de pedidos
SELECT COUNT(order_number) AS total_orders FROM gold.fact_sales
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales -- Retirar pedidos que estejam se repetindo

-- Encontre o número total de produtos
SELECT COUNT(product_key) AS total_product FROM gold.dim_products

-- Encontre o número total de consumidores
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers

-- Encontre o número total de consumidores que tenham feito um pedido
SELECT COUNT(DISTINCT customer_key) AS total_ordering_customers FROM gold.fact_sales

-- Criando um Report que mostra todas as métricas chave do negócio
SELECT 'Total Sales' as measure_name, SUM(sales_amount) AS measura_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' as measure_name, SUM(quantity) AS measura_value FROM gold.fact_sales
UNION ALL
SELECT 'Averige Price' as measure_name, AVG(price) AS measura_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products', COUNT(product_key) FROM gold.dim_products
UNION ALL
SELECT 'Total Nr. Customers', COUNT(customer_key) FROM gold.dim_customers

-- Encontre o número de consumidores por país
SELECT 
country,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- Encontre o número de consumidores por gênero
SELECT 
gender,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC

-- Encontre o total de produtos por categoria
SELECT 
category,
COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC

-- Qual o custo médio em cada categoria?
SELECT 
category,
AVG(cost) AS avg_costs
FROM gold.dim_products
GROUP BY category
ORDER BY avg_costs DESC

-- Qual a receita total gerada por cada categoria?
SELECT 
p.category,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC

-- Encontre a receita total gerada por cada consumidor
SELECT
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC

-- Qual a distribuição de itens vendidos por país?
SELECT
c.country,
SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
c.country
ORDER BY total_sold_items DESC

-- Quais 5 produtos geram a maior receita?
SELECT TOP 5
p.product_name,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

-- Mesmo resultado mas utilizando uma função do Window para maior flexibilidade
SELECT
*
FROM (
	SELECT
	p.product_name,
	SUM(f.sales_amount) total_revenue,
	ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount)DESC) AS rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
	GROUP BY p.product_name)t
WHERE rank_products <= 5

-- Quais são os 5 piores produtos em termo de vendas?
SELECT TOP 5
p.product_name,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC

-- Ache os 10 primeiros consumidores que geraram maior receita
SELECT TOP 10
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC

-- Ache os 3 consumidores com os menores números de pedidos feitos
SELECT TOP 3
c.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_orders ASC