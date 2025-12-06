# app/models/cart.rb
class Cart < ApplicationRecord
  # Associações
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  # ------------------------------------------------------------------
  # VALIDAÇÕES
  # ------------------------------------------------------------------

  # O spec exige que total_price não possa ser negativo.
  validates :total_price,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  # NÃO coloque validação de customer_name ou coisas extras aqui.
  # Isso quebra os testes que fazem Cart.create sem atributos.

  # ------------------------------------------------------------------
  # MÉTODOS DE NEGÓCIO
  # ------------------------------------------------------------------

  # Recalcula o total com base nos itens ligados ao carrinho.
  def recalculate_total_price!
    value = cart_items.includes(:product).sum do |item|
      item.quantity * item.product.unit_price
    end

    update!(total_price: value)
  end

  # Marca o carrinho como abandonado se estiver inativo há pelo menos 3 horas.
  def mark_as_abandoned
    return false if last_interaction_at.nil?
    return false if last_interaction_at > 3.hours.ago

    update(abandoned: true)
  end

  # Remove o carrinho se ele estiver abandonado há pelo menos 7 dias.
  def remove_if_abandoned
    return false unless abandoned?
    return false if last_interaction_at.nil?
    return false if last_interaction_at > 7.days.ago

    destroy
    true
  end

  # ------------------------------------------------------------------
  # OPERAÇÕES DE ITENS
  # ------------------------------------------------------------------

  def add_item!(product_id:, quantity:)
    transaction do
      item = cart_items.find_or_initialize_by(product_id: product_id)
      item.quantity = (item.quantity || 0) + quantity
      item.save!

      update!(last_interaction_at: Time.current)
      recalculate_total_price!
    end

    true
  end
end
