/*
========================================================================================
Report do Produto
========================================================================================
Objetivo:
	- Esse reporte consolida métricas chave e comportamentos do produto.

Destaques:
	1. Coleciona campos importantes como nomes, categoria, subcategoria e custo.
	2. Segmenta os produtos por receita para indentificar os que tem melhor desempenho, desempenho médio e baixo desempenho.
	3. Agrega métricas a nivel de produto:
		- número total de pedidos
		- número total de vendas
		- número total de pedidos vendidos
		- número total de consumidores (únicos)
		- vida útil (em meses)
	4. Calcula KPIs valiosas:
		- meses desde a última venda
		- valor média de receita
		- média de receita por mês
========================================================================================
*/
CREATE VIEW gold.report_products AS
WITH base_query AS(
/*-------------------------------------------------------------------------------------
1) Query Básica: Retorna as principais colunas das tabelas fact_sales e dim_products
---------------------------------------------------------------------------------------*/
SELECT
	f.order_number,
	f.order_date,
	f.customer_key,
	f.sales_amount,
	f.quantity,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
WHERE order_date IS NOT NULL)-- Só considera datas de vendas válidas

, product_aggregations AS (
/*-------------------------------------------------------------------------------------
2) Agregações: Sumariza métricas chave a nivel de produto
---------------------------------------------------------------------------------------*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_sale_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
FROM base_query
GROUP BY
	product_key,
	product_name,
	category,
	subcategory,
	cost
)

/*-------------------------------------------------------------------------------------
3) Query Final: Combina todos os resultados de produtos em um só resultado
---------------------------------------------------------------------------------------*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Receita média dos pedidos
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,
	-- Receita média por mês
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_montly_revenue
FROM product_aggregations