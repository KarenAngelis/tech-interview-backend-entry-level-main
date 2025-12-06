# spec/factories/carts.rb
# O 'require' é necessário para usar o Faker nas factories
require 'faker'

FactoryBot.define do
  
  factory :product do
    # Usando Faker para dados realistas e únicos, e valores que satisfazem suas validações
    name { Faker::Commerce.product_name }
    unit_price { Faker::Commerce.price(range: 10.00..100.00) }
    cost_price { Faker::Commerce.price(range: 5.00..50.00) }
    stock { Faker::Number.between(from: 50, to: 500) }
  end

  # Factory para o carrinho
  # Usa 'aliases: [:shopping_cart]' para corrigir o erro KeyError
  factory :cart, aliases: [:shopping_cart] do
    # 🔑 CORREÇÃO: Usando 'sequence' em vez de 'Faker' para o atributo customer_name
    # Isso resolve o NoMethodError: undefined method 'customer_name=' no contexto do Factory Bot.
    sequence(:customer_name) { |n| "Cliente de Teste #{n}" } 
    
    # Garante que a coluna last_interaction_at seja preenchida (requisito do desafio)
    last_interaction_at { Time.current }

    # Trait para criar um carrinho com itens (útil para testes)
    trait :with_items do
      after(:create) do |cart|
        create_list(:cart_item, 2, cart: cart) # Cria 2 CartItems
      end
    end
  end

  factory :cart_item do
    # Associações Factory Bot (cria um objeto cart e product automaticamente)
    cart
    product
    quantity { 1 }
  end
end