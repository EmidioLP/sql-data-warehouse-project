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
