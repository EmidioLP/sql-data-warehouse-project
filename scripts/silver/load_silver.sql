/*
=============================================================================
Procedimento que carrega a camada de silver: (BRONZE -> SILVER)
=============================================================================
Objetivo do Script:
	Esse procedimento carrega os dados na camada de 'silver' diretamente da camada 'bronze'.
	Ele performar as seguintes ações:
		- Exclui as tabelas na camada silver antes de carregar os dados (truncate).
		- Usa o comando 'INSERT INTO' para carregar arquivos da camada 'bronze' para a camada 'silver' após realizar os processos de limpeza dos dados.

	Parâmetros:
		Nenhum.
			Esse procedimento não aceita nenhum parâmetro e não retorna nenhum valor.

	Exemplo de Utilização:
		EXEC silver.load_silver;
============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '===================================================';
		PRINT 'Carregando a camada silver';
		PRINT '===================================================';

		PRINT '---------------------------------------------------';
		PRINT 'Carregando as tabelas CRM';
		PRINT '---------------------------------------------------';

		-- Carregando silver.crm_cust_info
		PRINT '>> Excluindo (Truncate) a Tabela: crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		SET @start_time = GETDATE();
		PRINT '>> Inserindo os Dados na Tabela: crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
			)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				 ELSE 'n/a'
			END cst_marital_status, -- Normalização dos valores de 'marital_status' para um formato mais legível
			CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				 ELSE 'n/a'
			END cst_gndr, -- Normalização dos valores de 'cst_gndr' para um formato mais legível
			cst_create_date
			FROM (
				SELECT
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
				FROM bronze.crm_cust_info
				WHERE cst_id IS NOT NULL
		)t 
		WHERE flag_last = 1 -- Seleciona o recorte mais recente por cliente (remove duplicatas)
		SET @end_time = GETDATE();
		PRINT '>> Duração do carregamento: ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' segundos';
		PRINT '------------------------';

		-- Carregando silver.crm_prd_info
		PRINT '>> Excluindo (Truncate) a Tabela: silver.crm_prd_info';
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Inserindo os Dados na Tabela: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
			)
		SELECT
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extrai o id da categoria
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, -- Extrai o id do produto
			prd_nm,
			ISNULL(prd_cost,  0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				 WHEN 'M' THEN 'Mountain'
				 WHEN 'R' THEN 'Road'
				 WHEN 'S' THEN 'Other Sales'
				 WHEN 'T' THEN 'Touring'
				 ELSE 'n/a'
			END AS prd_line, -- Mapeia para um valor mais descritivo
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(
				LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 
				AS DATE
			) AS prd_end_dt -- Calcula o fim da data como um dia antes do começo da data inicial
		FROM bronze.crm_prd_info
		SET @end_time = GETDATE();
		PRINT '>> Duração do carregamento: ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' segundos';
		PRINT '------------------------';

		-- Carregando silver.crm_sales_details
		PRINT '>> Excluindo (Truncate) a Tabela: silver.crm_sales_details';
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserindo os Dados na Tabela: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
			)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) !=8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) !=8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) !=8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
					THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales, -- Recalcula 'sales' se o valor original estiver faltando ou incorreto
				sls_quantity,
			CASE WHEN sls_price IS NULL OR sls_price <=0
					THEN sls_sales / NULLIF(sls_quantity,0)
				ELSE sls_price -- Deriva o preço se o valor original é inválido
			END AS sls_price
		FROM bronze.crm_sales_details
		SET @end_time = GETDATE();
		PRINT '>> Duração do carregamento: ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' segundos';
		PRINT '------------------------';

		PRINT '---------------------------------------------------';
		PRINT 'Carregando as tabelas ERP';
		PRINT '---------------------------------------------------';

		-- Carregando silver.erp_cust_az12
		PRINT '>> Excluindo (Truncate) a Tabela: silver.erp_cust_az12';
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Inserindo os Dados na Tabela: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		SELECT 
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4,LEN(cid))
				ELSE cid
			END AS cid,
			CASE WHEN bdate > GETDATE() THEN NULL
				 ELSE bdate
			END AS bdate, -- Coloca os aniversários no futuro como NULOS
			CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				 ELSE 'n/a'
			END AS gen -- Normaliza os valores de gênero para tratar casos desconhecidos
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>> Duração do carregamento: ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' segundos';
		PRINT '------------------------';

		-- Carregando silver.erp_loc_a101
		PRINT '>> Excluindo (Truncate) a Tabela: silver.erp_loc_a101';
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserindo os Dados na Tabela: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101(
			cid,
			cntry
		)
		SELECT 
			REPLACE(cid,'-','') cid,
			CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				 ELSE TRIM(cntry)
			END AS cntry -- Normaliza e Trata valores faltantes ou códigos de país em branco
		FROM bronze.erp_loc_a101
		SET @end_time = GETDATE();
		PRINT '>> Duração do carregamento: ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' segundos';
		PRINT '------------------------';

		-- Carregando silver.erp_px_cat_g1v2
		PRINT '>> Excluindo (Truncate) a Tabela: silver.erp_px_cat_g1v2';
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Inserindo os Dados na Tabela: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2
		SET @end_time = GETDATE();
		PRINT '>> Duração do carregamento: ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' segundos';
		PRINT '------------------------';

		SET @batch_end_time = GETDATE();
		PRINT'==============================================================';
		PRINT'O carregamento da camada silver foi completado!';
		PRINT'     - Duração total do carregamento: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT'==============================================================';
	END TRY
	BEGIN CATCH
	PRINT '===================================================================';
		PRINT 'ACONTECEU UM ERRO DURANTE O CARREGAMENTO DA CAMADA SILVER';
		PRINT 'Mensagem de Erro' + ERROR_MESSAGE();
		PRINT 'Número do Erro' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Estado do Erro' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '===================================================================';
	END CATCH
END