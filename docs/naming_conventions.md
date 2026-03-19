# **Convenções de nomenclatura**

Este documento descreve as convenções de nomenclatura usadas para esquemas, tabelas, visualizações, colunas e outros objetos no data warehouse.

## **Tabela de Conteúdos**

1. [Princípios Gerais](#princípios-gerais)
2. [Convenções de nomenclatura de tabelas](#convenções-de-nomenclatura-de-tabelas)
   - [Regras Bronze](#regras-bronze)
   - [Regras Silver](#regras-silver)
   - [Regras Gold](#regras-gold)
3. [Convenções de nomenclatura de colunas](#convenções-de-nomenclatura-de-colunas)
   - [Chaves substituitas](#chaves-substitutas)
   - [Colunas técnicas](#colunas-técnicas)
4. [Stored Procedure](#stored-procedure)
---

## **Princípios Gerais**

- **Convenções de nomenclatura**: Use snake_case, com letras minúsculas e sublinhados (`_`) para separar as palavras.
- **Idioma**: Use inglês para todos os nomes.
- **Evite palavras reservadas**: Não use palavras reservadas do SQL como nomes de objetos.

## **Convenções de nomenclatura de tabelas**

### **Regras Bronze**
- Todos os nomes devem começar com o nome do sistema de origem e os nomes das tabelas devem corresponder aos seus nomes originais, sem serem renomeados.
- **`<sourcesystem>_<entity>`**
  - `<sourcesystem>`: Nome do sistema de origem (por exemplo, `crm`, `erp`).  
  - `<entity>`: Nome exato da tabela do sistema de origem.  
  - Exemplo: `crm_customer_info` → Informações do cliente provenientes do sistema CRM.

### **Regras Silver**
- Todos os nomes devem começar com o nome do sistema de origem e os nomes das tabelas devem corresponder aos seus nomes originais, sem serem renomeados.
- **`<sourcesystem>_<entity>`**
  - `<sourcesystem>`: Nome do sistema de origem (por exemplo, `crm`, `erp`).  
  - `<entity>`: Nome exato da tabela do sistema de origem.  
  - Exemplo: `crm_customer_info` → Informações do cliente provenientes do sistema CRM.

### **Regras Gold**
- Todos os nomes devem ser significativos e alinhados com o negócio para as tabelas, começando com o prefixo da categoria.
- **`<category>_<entity>`**  
  - `<category>`: Descreve a função da tabela, como `dim` (dimensão) ou `fact` (tabela de fatos).  
  - `<entity>`: Nome descritivo da tabela, alinhado com o domínio de negócios (por exemplo, `clientes`, `produtos`, `vendas`). 
  - Exemplos:
    - `dim_customers` → Tabela de dimensões para dados do cliente.  
    - `fact_sales` → Tabela de fatos contendo transações de vendas.  

#### **Glossário de Padrões de Categoria**

|  Padrão     | Significado                           | Exemplo(s)                              |
|-------------|-----------------------------------|-----------------------------------------|
| `dim_`      | Tabela de Dimensão                | `dim_customer`, `dim_product`           |
| `fact_`     | Tabela de Fato                    | `fact_sales`                            |
| `report_`   | Tabela de Report                  | `report_customers`, `report_sales_monthly`   |

## **Convenções de nomenclatura de colunas**

### **Chaves substitutas**  
- Todas as chaves primárias em tabelas de dimensão devem usar o sufixo `_key`.
- **`<table_name>_key`**  
  - `<table_name>`: Refere-se ao nome da tabela ou entidade à qual a chave pertence.  
  - `_key`: Um sufixo indicando que esta coluna é uma chave substituta.  
  - Exemplo: `customer_key` → Chave substituta na tabela `dim_customers`.
  
### **Colunas Técnicas**
- Todas as colunas técnicas devem começar com o prefixo `dwh_`, seguido por um nome descritivo que indique a finalidade da coluna.
- **`dwh_<column_name>`**  
  - `dwh`: Prefixo exclusivo para metadados gerados pelo sistema.  
  - `<column_name>`: Nome descritivo que indica a finalidade da coluna.  
  - Exemplo: `dwh_load_date` → Coluna gerada pelo sistema usada para armazenar a data em que o registro foi carregado.
 
## **Stored Procedure**

- Todos as Stored Procedures usadas ​​para carregar dados devem seguir o padrão de nomenclatura:
- **`load_<layer>`**.
  - `<layer>`: Representa a camada que está sendo carregada, como `bronze`, `silver` ou `gold`.
  - Exemplo: 
    - `load_bronze` → Stored procedure para carregar a camada bronze.
    - `load_silver` → Stored procedure para carregar a camada silver.
