/*
========================================================================================
Report do Consumidor
========================================================================================
Objetivo:
	- Esse reporte consolida métricas chave e comportamentos do consumidor.

Destaques:
	1. Coleciona campos importantes como nomes, idades e detalhes transacionais.
	2. Segmenta os consumidores em categorias (VIP, Regular, New) e grupos de idade.
	3. Agrega métricas a nivel de consumidor:
		- número total de pedidos
		- número total de vendas
		- número total de compras
		- número total de produtos
		- vida útil (em meses)
	4. Calcula KPIs valiosas:
		- meses desde o último pedido
		- valor médio do pedido
		- média de gastos no mês
========================================================================================
*/
CREATE VIEW gold.report_customers AS 
WITH base_query AS (
/*-------------------------------------------------------------------------------------
1) Query Básica: Retorna as principais colunas da tabela
---------------------------------------------------------------------------------------*/
SELECT 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
DATEDIFF(year, c.birthdate, GETDATE()) age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
WHERE order_date IS NOT NULL)

, customer_aggregation AS (
/*-------------------------------------------------------------------------------------
2) Agregações: Sumariza métricas chave a nivel de consumidor
---------------------------------------------------------------------------------------*/
SELECT 
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT product_key) AS total_products,
MAX (order_date) AS last_order_date,
DATEDIFF(month, MIN(order_date),MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age
)
SELECT 
customer_key,
customer_number,
customer_name,
age,
CASE 
	 WHEN age < 20 THEN 'Under 20'
	 WHEN age BETWEEN 20 AND 29 THEN '20-29'
	 WHEN age BETWEEN 20 AND 39 THEN '30-39'
	 WHEN age BETWEEN 40 AND 49 THEN '40-49'
	 ELSE '50 and Above'
END AS age_group,
CASE 
	 WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
	 ELSE 'New'
END AS customer_segment,
last_order_date,
DATEDIFF(month, last_order_date, GETDATE()) AS recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
-- Computa a média de valor dos pedidos (AVO)
CASE WHEN total_sales = 0 THEN 0 
	 ELSE total_sales / total_orders
END AS avg_order_value,
-- Computa a média de gastos por mês
CASE WHEN lifespan = 0 THEN total_sales
	 ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customer_aggregation