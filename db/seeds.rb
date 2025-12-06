# db/seeds.rb

puts "Criando produtos iniciais..."

# Assegure que as colunas 'name' e 'cost_price' (ou 'unit_price') 
# existem nas suas migrations antes de usar este código.
Product.create!([
  {
    name: 'Samsung Galaxy S24 Ultra',
    # Use o nome da coluna que está na sua migration (unit_price ou cost_price)
    unit_price: 14999.99, 
    cost_price: 10000.00,
    stock: 50
  },
  {
    name: 'iPhone 15 Pro Max',
    unit_price: 17999.99,
    cost_price: 12000.00,
    stock: 75
  },
  {
    name: 'Xiamo Mi 27 Pro Plus Master Ultra',
    unit_price: 999.99,
    cost_price: 600.00,
    stock: 120
  }
])

puts "Produtos criados com sucesso! Total: #{Product.count}"