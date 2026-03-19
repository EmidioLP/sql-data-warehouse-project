/*
===============================================================================
Checagem de Qualidade
===============================================================================
Propósito do Script:
    Este script realiza diversas verificações de qualidade para consistência e precisão dos dados, 
    e padronização em toda a camada 'prateada'. Isso inclui verificações para:
    - Chaves primárias nulas ou duplicadas.
    - Espaços indesejados em campos de texto.
    - Padronização e consistência de dados.
    - Intervalos de datas e ordens inválidos.
    - Consistência de dados entre campos relacionados.

Notas de utilização:
    - Execute essas verificações após o carregamento dos dados na camada Silver.
    - Investigue e resolva quaisquer discrepâncias encontradas durante as verificações.
===============================================================================
*/

-- ====================================================================
-- Checando 'silver.crm_cust_info'
-- ====================================================================
-- Check por Nulos ou Duplicatas nas chaves primárias
-- Esperado: Nenhum Resultado
SELECT 
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Checand por espaços indesejados
-- Esperado: Nenhum resultado
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Padronização e consistência de dados
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;

-- ====================================================================
-- Checando 'silver.crm_prd_info'
-- ====================================================================
-- Check por Nulos ou Duplicatas nas chaves primárias
-- Esperado: Nenhum Resultado
SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Checando por espaços indesejados
-- Esperado: Nenhum resultado
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Checando por Nulos ou Valores negativos em cost
-- Esperado: Nenhum resultado
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Padronização e consistência de dados
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Checando por datas inválidas (Start_date > End_date)
-- Esperado: Nenhum Resultado
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- Checando 'silver.crm_sales_details'
-- ====================================================================
-- Check por Datas Inválidas
-- Esperado: Nenhuma data inválida
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;

-- Checando por Date Order inválidas (Order Date > Due Dates)
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Checando consistência dos dados: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- Checando 'silver.erp_cust_az12'
-- ====================================================================
-- Indentificândo dados out-of-range
-- Espectativa: Datas de aniverário entre 1924-01-01 e Hoje (dia da criação do script)
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- Padronização e consistência de dados
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;

-- ====================================================================
-- Checando 'silver.erp_loc_a101'
-- ====================================================================
-- Padronização e consistência de dados
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Checando 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- Checando por espaços indesejados
-- Expectativa: Nenhum resultado
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Padronização e consistência de dados
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;
