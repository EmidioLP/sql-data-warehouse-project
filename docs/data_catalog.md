# Catálogo de dados para a camada gold

## Overview
A Camada Gold é a representação de dados em nível de negócios, estruturada para dar suporte a casos de uso analíticos e de geração de relatórios. Ela consiste em **tabelas de dimensão** e **tabelas de fatos** para métricas de negócios específicas.

---

### 1. **gold.dim_customers**
- **Propósito:** Armazena detalhes do cliente enriquecidos com dados demográficos e geográficos.
- **Colunas:**

| Nome da Coluna   | Data Type     | Descrição                                                                                      |
|------------------|---------------|------------------------------------------------------------------------------------------------|
| customer_key     | INT           | Chave substituta que identifica exclusivamente cada registro de cliente na tabela de dimensões.|
| customer_id      | INT           | Identificador numérico único atribuído a cada cliente.                                         |
| customer_number  | NVARCHAR(50)  | Identificador alfanumérico que representa o cliente, usado para rastreamento e referência.     |
| first_name       | NVARCHAR(50)  | O primeiro nome do cliente, conforme registrado no sistema.                                    |
| last_name        | NVARCHAR(50)  | O sobrenome ou nome de família do cliente.                                                     |
| country          | NVARCHAR(50)  | O país de residência do cliente (por exemplo, 'Austrália').                                    |
| marital_status   | NVARCHAR(50)  | O estado civil do cliente (por exemplo, 'Married', 'Single').                                  |
| gender           | NVARCHAR(50)  | O gênero do cliente (por exemplo, 'Male', 'Female', 'n/a').                                    |
| birthdate        | DATE          | A data de nascimento do cliente, formatada como AAAA-MM-DD (ex.: 1971-10-06).                  |
| create_date      | DATE          | A data e a hora em que o registro do cliente foi criado no sistema.                            |

---

### 2. **gold.dim_products**
- **Propósito:** Fornece informações sobre os produtos e seus atributos.
- **Colunas:**

| Nome da Coluna      | Data Type     | Descrição                                                                                                                    |
|---------------------|---------------|------------------------------------------------------------------------------------------------------------------------------|
| product_key         | INT           | Chave substituta que identifica exclusivamente cada registro de produto na tabela de dimensões do produto.                   |
| product_id          | INT           | Um identificador único atribuído ao produto para fins de rastreamento e referência internos.                                 |
| product_number      | NVARCHAR(50)  | Um código alfanumérico estruturado que representa o produto, frequentemente usado para categorização ou controle de estoque. |
| product_name        | NVARCHAR(50)  | Nome descritivo do produto, incluindo detalhes importantes como tipo, cor e tamanho.                                         |
| category_id         | NVARCHAR(50)  | Um identificador único para a categoria do produto, que o vincula à sua classificação de alto nível.                         |
| category            | NVARCHAR(50)  | A classificação mais ampla do produto (por exemplo, Bicycles, Components) para agrupar itens relacionados.                   |
| subcategory         | NVARCHAR(50)  | Uma classificação mais detalhada do produto dentro da categoria, como por exemplo, o tipo de produto.                        |
| maintenance_required| NVARCHAR(50)  | Indica se o produto necessita de manutenção (ex.: 'Yes', 'No').                                                              |
| cost                | INT           | O custo ou preço base do produto, medido em unidades monetárias.                                                             |
| product_line        | NVARCHAR(50)  | A linha de produtos ou série específica à qual o produto pertence (por exemplo, Road, Mountain).                             |
| start_date          | DATE          | A data em que o produto ficou disponível para venda ou uso, armazenada.                                                      |

---

### 3. **gold.fact_sales**
- **Propósito:** Armazena dados de vendas transacionais para fins analíticos.
- **Colunas:**

| Nome da Coluna  | Data Type     | Descrição                                                                                                |
|-----------------|---------------|----------------------------------------------------------------------------------------------------------|
| order_number    | NVARCHAR(50)  | Um identificador alfanumérico único para cada pedido de venda (por exemplo, 'SO54496').                  |
| product_key     | INT           | Chave substituta que vincula o pedido à tabela de dimensões do produto.                                  |
| customer_key    | INT           | Chave substituta que vincula o pedido à tabela de dimensões do cliente.                                  |
| order_date      | DATE          | A data em que o pedido foi feito.                                                                        |
| shipping_date   | DATE          | A data em que o pedido foi enviado ao cliente.                                                           |
| due_date        | DATE          | A data em que o pagamento do pedido vencia.                                                              |
| sales_amount    | INT           | O valor monetário total da venda do item, em unidades monetárias inteiras (por exemplo, 25).             |
| quantity        | INT           | O número de unidades do produto encomendadas para o item da lista (por exemplo, 1).                      |
| price           | INT           | O preço por unidade do produto para o item em questão, em unidades monetárias inteiras (por exemplo, 25).|
