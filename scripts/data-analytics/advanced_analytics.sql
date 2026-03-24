/*
==========================================================================================
Objetivo:
	Contém uma magnitude de Scripts que demonstram técnicas de análise de dados mais avançadas
	como o tempo de transição (trends), análise cumulativa e análise de performance.
==========================================================================================
*/

-- Quantos consumidores foram adicionados cada ano
SELECT
DATETRUNC(year, create_date) as create_year,
COUNT(customer_key) as total_customer
FROM gold.dim_customers
GROUP BY DATETRUNC(year, create_date)
ORDER BY DATETRUNC(year, create_date)

-- Cálculo de total de vendas por ano
-- e o total acumulado de vendas ao longo do tempo
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) as running_total_sales
FROM
(
SELECT
DATETRUNC(year,order_date) as order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
) t 

/* Análise da performance anual dos produtos comparando suas vendas com tanto o 
desempenho médio de vendas quanto as vendas de anos anteriores. */
WITH yearly_product_sales AS(
SELECT
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) as current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY 
YEAR(f.order_date),
p.product_name
)
SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
	 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
	 ELSE 'Avg'
END avg_change,
-- Análise ano a ano
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	 ELSE 'No Change'
END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year

-- Qual categoria contribui mais nas vendas?
WITH category_sales AS(
SELECT 
category,
SUM(sales_amount) total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p 
ON p.product_key = f.product_key
GROUP BY category
)
SELECT 
category,
total_sales,
SUM(total_sales) OVER () overall_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) *100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC

/* Segmentação dos produtos em um range de preços e 
contagem de quantos produtos são classificados em cada segmento */
WITH product_segments AS (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END cost_range
FROM gold.dim_products)

SELECT
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC

/*
Agrupamento de cosumidores em três segmentos baseado em como gastam:
	- VIP: Consumidores com no mínimo 12 meses de história e gastando mais de €5,000.
	- Regular: Consumidores com no mínimo 12 meses de história mas gastando €5,000 ou menos.
	- New: Consumidores com menos de 12 meses de história.
E o número total de consumidores em cada grupo.
*/
WITH customer_spending AS(
SELECT 
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) first_order,
MAX(order_date) AS last_order,
DATEDIFF(month, MIN(order_date),MAX(order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key)

SELECT
customer_segment,
COUNT(customer_key) AS total_customers
FROM (
	SELECT 
	customer_key,
	CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		 ELSE 'New'
	END customer_segment
	FROM customer_spending) t
GROUP BY customer_segment
ORDER BY total_customers DESC