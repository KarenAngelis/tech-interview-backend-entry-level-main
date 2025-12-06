class Product < ApplicationRecord
  # Mapeamento do atributo: Permite que o código e os testes usem :price
  # mesmo que a coluna real no DB seja :unit_price.
  alias_attribute :price, :unit_price

  validates_presence_of :name
  
  # 🔑 CORREÇÃO: Mudar a validação para o atributo :price (que é o que o teste espera)
  validates_presence_of :price
  validates_numericality_of :price, greater_than_or_equal_to: 0

  validates_presence_of :cost_price
  validates_numericality_of :cost_price, greater_than_or_equal_to: 0
  
  validates_presence_of :stock
  validates_numericality_of :stock, only_integer: true, greater_than_or_equal_to: 0
end