/*
=============================================================================
Procedimento que carrega a camada de bronze: (FONTE -> BRONZE)
=============================================================================
Objetivo do Script:
	Esse procedimento carrega os dados na camada de 'bronze' de arquivos CSV externos.
	Ele performar as seguintes ações:
		- Exclui as tabelas na camada de bronze antes de carregar os dados (truncate).
		- Usa o comando 'BULK INSERT' para carregar arquivos do tipo CSV para as tabelas na camada de 'bronze'.
	
	Parâmetros:
		Nenhum.
			Esse procedimento não aceita nenhum parâmetro e não retorna nenhum valor.

	Exemplo de Utilização:
		EXEC bronze.load_bronze;

	OBSERVAÇÃO:
		Certifique-se de que o caminho do arquivo esteja idêntico ao no seu computador!
============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '===================================================';
		PRINT 'Carregando a camada de bronze';
		PRINT '===================================================';

		PRINT '---------------------------------------------------';
		PRINT 'Carregando as tabelas CRM';
		PRINT '---------------------------------------------------';

		PRINT'>> Excluindo (truncating) a tabela: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		-- Carregando bronze.crm_cust_info
		SET @start_time = GETDATE();
		PRINT'>> Inserindo os dados na tabela: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Duração do carregamento: ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' segundos';
		PRINT '------------------------';

		-- Carregando bronze.crm_prd_info
		PRINT'>> Excluindo (truncating) a tabela: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		SET @start_time = GETDATE();
		PRINT'>> Inserindo os dados na tabela: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'sql-data-warehouse-project\datasets\source_crm/prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Duração do carregamento: ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' segundos';
		PRINT '------------------------';

		-- Carregando bronze.crm_sales_details
		PRINT'>> Excluindo (truncating) a tabela: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		SET @start_time = GETDATE();
		PRINT'>> Inserindo os dados na tabela: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'sql-data-warehouse-project\datasets\source_crm/sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Duração do carregamento: ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' segundos';
		PRINT '------------------------';

		PRINT '---------------------------------------------------';
		PRINT 'Carregando as tabelas ERP';
		PRINT '---------------------------------------------------';

		-- Carregando bronze.erp_cust_az12
		PRINT'>> Excluindo (truncating) a tabela: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		SET @start_time = GETDATE();
		PRINT'>> Inserindo os dados na tabela: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'sql-data-warehouse-project\datasets\source_erp/CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Duração do carregamento: ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' segundos';
		PRINT '------------------------';

		-- Carregando bronze.erp_loc_a101
		PRINT'>> Excluindo (truncating) a tabela: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		SET @start_time = GETDATE();
		PRINT'>> Inserindo os dados na tabela: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'sql-data-warehouse-project\datasets\source_erp/LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Duração do carregamento: ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' segundos';
		PRINT '------------------------';

		-- Carregando bronze.erp_px_cat_g1v2
		PRINT'>> Excluindo (truncating) a tabela: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		SET @start_time = GETDATE();
		PRINT'>> Inserindo os dados na tabela: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'sql-data-warehouse-project\datasets\source_erp/PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Duração do carregamento: ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' segundos';
		PRINT '------------------------';

		SET @batch_end_time = GETDATE();
		PRINT'==============================================================';
		PRINT'O carregamento da camada de bronze foi completado!';
		PRINT'     - Duração total do carregamento: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT'==============================================================';
	END TRY
	BEGIN CATCH
		PRINT '===================================================================';
		PRINT 'ACONTECEU UM ERRO DURANTE O CARREGAMENTO DA CAMADA DE BRONZE';
		PRINT 'Mensagem de Erro' + ERROR_MESSAGE();
		PRINT 'Número do Erro' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Estado do Erro' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '===================================================================';
	END CATCH
END