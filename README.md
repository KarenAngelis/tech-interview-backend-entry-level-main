# Desafio técnico – E-commerce (Carrinho de compras)

API em Ruby on Rails para gestão de carrinho de compras de um e-commerce, implementada como parte do desafio técnico da RD Station.

## Stack / Dependências

- Ruby 3.3.1  
- Rails 7.1.3.2  
- PostgreSQL 16  
- Redis 7.0.15  
- Sidekiq (processamento de jobs)

---

## Como executar com Docker

Pré-requisito: Docker instalado e funcionando.

### Subir a aplicação

Se você estiver usando Docker Compose v2:

docker compose up web
Se estiver usando a versão antiga:


docker-compose up web
A API ficará disponível em:

http://localhost:3000
Executar a suíte de testes

# Compose v2
docker compose up test

# ou
docker-compose up test
Como executar sem Docker
Assumindo Ruby, PostgreSQL e Redis instalados e configurados:

Instalar dependências:


bundle install
Criar/migrar o banco (se necessário):

bundle exec rails db:create db:migrate
Subir o Sidekiq:

bundle exec sidekiq
Subir o servidor Rails:

bundle exec rails server
Rodar os testes:

bundle exec rspec
Documentação da API
1. GET /cart
Lista os itens do carrinho atual.

Regras
A cart_id do carrinho atual é armazenada na sessão (session[:cart_id]).

Se não existir carrinho na sessão, o endpoint responde com erro apropriado (404).

Exemplo de resposta

{
  "id": 1,
  "products": [
    {
      "id": 1,
      "name": "Samsung Galaxy S24 Ultra",
      "quantity": 1,
      "unit_price": "12999.99",
      "total_price": "12999.99"
    }
  ],
  "total_price": "12999.99"
}
2. POST /cart
Cria um carrinho (se ainda não existir na sessão) e/ou adiciona um produto.

Regras
product_id deve ser o ID de um produto existente.

quantity deve ser um inteiro positivo.

Se não houver cart_id na sessão, um novo carrinho é criado e seu id é salvo em session[:cart_id].

Responde com 201 Created quando um novo carrinho é criado, conforme semântica HTTP.

Payload de exemplo

{
  "product_id": 1,
  "quantity": 2
}
Exemplo de resposta

{
  "id": 1,
  "products": [
    {
      "id": 1,
      "name": "Samsung Galaxy S24 Ultra",
      "quantity": 2,
      "unit_price": "12999.99",
      "total_price": "25999.98"
    }
  ],
  "total_price": "25999.98"
}
3. POST /cart/add_item
Altera a quantidade de um produto em um carrinho existente (adicionando unidades).

Regras
A cart_id deve estar presente na sessão.

product_id deve existir.
quantity deve ser inteiro positivo.

Se o produto não estiver no carrinho, ele é adicionado.
Se o produto já estiver no carrinho, apenas a quantidade é atualizada.

Payload de exemplo

{
  "product_id": 1,
  "quantity": 1
}
Exemplo de resposta

{
  "id": 1,
  "products": [
    {
      "id": 1,
      "name": "Samsung Galaxy S24 Ultra",
      "quantity": 3,
      "unit_price": "12999.99",
      "total_price": "38999.97"
    }
  ],
  "total_price": "38999.97"
}
4. DELETE /cart/:product_id
Remove um produto do carrinho atual.

Regras
A cart_id deve estar presente na sessão.

product_id deve existir dentro do carrinho.

Caso o produto não esteja no carrinho, é retornado erro 404 com mensagem apropriada.

Em caso de sucesso, o endpoint retorna 204 No Content, seguindo boas práticas REST.

Carrinhos abandonados
Um carrinho é considerado abandonado quando fica mais de 3 horas sem interação (adição ou remoção de itens).

Regra de negócio implementada:

Após 3 horas sem interação, o carrinho passa a ser marcado como abandoned = true.

Carrinhos abandonados por mais de 7 dias são removidos da base.

Essa lógica é centralizada:

No model Cart, por meio dos métodos:
mark_as_abandoned – marca o carrinho como abandonado, dado o tempo de inatividade.
remove_if_abandoned – remove carrinhos abandonados há mais de 7 dias.
No job AbandonedCartsJob, que chama esses métodos usando Sidekiq.

Observação: o agendamento periódico do job (cron / scheduler) pode ser feito via Sidekiq Scheduler ou sidekiq-cron, conforme o ambiente de execução. No desafio, o foco ficou na implementação da regra de negócio e dos testes unitários.

Testes
A suíte de testes cobre:
ProductsController – criação, listagem, atualização e exclusão de produtos;

Cart (model):

validações de total_price;
marcação e remoção de carrinhos abandonados;
atualização de last_interaction_at quando há interação;

CartsController:

rotas /cart, /cart/add_item e DELETE /cart/:product_id.

Observações sobre testes pendentes
O arquivo spec/requests/carts_spec.rb mantém dois testes marcados como pending:

Um lembrete genérico para adicionar mais testes de request para o controller;

Um teste original do desafio que usa o endpoint /cart/add_items (plural) e não lida com sessão, enquanto a implementação final segue o endpoint /cart/add_item (singular) e depende de session[:cart_id].

A lógica do carrinho é coberta pelos testes de model e de controller, que permitem manipular a sessão de forma adequada.

Padrões e decisões de design
Status HTTP:

201 Created em criações de recursos;
200 OK em operações bem-sucedidas com corpo de resposta;
204 No Content em deleções bem-sucedidas sem corpo de resposta;
404 Not Found e 422 Unprocessable Entity para erros de regra de negócio/validação.
Clean code / legibilidade:
Controllers pequenos, empurrando regras de negócio para o model Cart;
Uso de factories (FactoryBot) para construção de objetos em testes;
Métodos privados no controller para validações e tratamento de erros.

Autora: Karen Angelis