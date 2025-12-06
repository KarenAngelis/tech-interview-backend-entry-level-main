class CartItem < ApplicationRecord
  # Associações necessárias para o carrinho de compras
  belongs_to :cart 
  belongs_to :product
  
  # Adicione aqui as validações para 'quantity' (e.g., maior que zero)
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
end