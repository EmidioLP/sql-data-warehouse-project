/*
===============================================================================
Checagem de qualidade
===============================================================================
Propósito do Script:
    Este script realiza verificações de qualidade para validar a integridade, consistência,
    e a precisão da camada de ouro. Essas verificações garantem:
    - Unicidade das chaves substitutas nas tabelas de dimensão.
    - Integridade referencial entre tabelas de fatos e de dimensões.
    - Validação das relações no modelo de dados para fins analíticos.

Notas de utilização:
    - Investigar e resolver quaisquer discrepâncias encontradas durante as verificações.
===============================================================================
*/

-- ====================================================================
-- Checando 'gold.dim_customers'
-- ====================================================================
-- Verifica a unicidade da Customer Key em gold.dim_customers
-- Expectativa: Nenhum Resultado
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checando 'gold.product_key'
-- ====================================================================
-- Verifica a unicidade da Product Key em gold.dim_products
-- Expectativa: Nenhum Resultado
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checando 'gold.fact_sales'
-- ====================================================================
-- Verifique a conectividade do modelo de dados entre fatos e dimensões.
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL  
