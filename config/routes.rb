
Rails.application.routes.draw do
  # Rotas para Products (necessário para os testes que criam produtos)
  resources :products 
  
  # Rotas de Carrinho
  # resource :cart mapeia: GET /cart e POST /cart 
  resource :cart, only: [:show, :create], controller: 'carts' 
  
  # ROTA: POST /cart/add_item (Alterar quantidade)
  post '/cart/add_item', to: 'carts#add_item'

  # ROTA: DELETE /cart/:product_id (Remover produto)
  delete '/cart/:product_id', to: 'carts#remove_item' 

end