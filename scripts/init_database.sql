/*
==================================================================
Criando a Base de Dados e os Esquemas
==================================================================
Propósito do script:
    Esse script cria uma nova base de dados chamada 'DataWarehouse' após checar se ela já existe.
    Se já existe, ele a exclui e depois recria. Adicionalmente, ele cria os esquemas 'bronze', 'silver' e 'gold'.
*/

USE master;
GO

-- Apaga e recrie a base de dados 'DataWarehouse'
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE   DataWarehouse;
END;
GO

-- Cria a base de dados
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Cria os esquemas
CREATE SCHEMA bronze;
GO
  
CREATE SCHEMA silver;
GO
  
CREATE SCHEMA gold;
GO
