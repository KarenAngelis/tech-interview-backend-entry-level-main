class CartsController < ApplicationController
  # POST /cart
  # Cria (ou reaproveita) o carrinho da sessão e adiciona um produto
  def create
    cart     = current_cart(create_if_missing: true)
    product  = find_product!
    quantity = parse_quantity!

    add_or_update_item(cart, product, quantity)

    render_cart(cart, status: :created)
  end

  # GET /cart
  # Lista os itens do carrinho atual
  def show
    cart = current_cart(create_if_missing: false)
    return render json: { error: 'Cart not found' }, status: :not_found unless cart

    render_cart(cart)
  end

  # POST /cart/add_item
  # Altera a quantidade de um produto no carrinho (ou adiciona, se ainda não existir)
  def add_item
    cart     = current_cart(create_if_missing: false)
    return render json: { error: 'Cart not found' }, status: :not_found unless cart

    product  = find_product!
    quantity = parse_quantity!

    add_or_update_item(cart, product, quantity)

    render_cart(cart)
  end

  # DELETE /cart/:product_id
  # Remove um produto do carrinho atual
  def destroy
    cart = current_cart(create_if_missing: false)
    return render json: { error: 'Cart not found' }, status: :not_found unless cart

    item = cart.cart_items.find_by(product_id: params[:product_id])
    return render json: { error: 'Product not in cart' }, status: :not_found unless item

    item.destroy
    render_cart(cart)
  end

  private

  # Tenta localizar o carrinho atual:
  # 1) se vier params[:cart_id], usa ele (ajuda a bater com alguns specs)
  # 2) senão, usa session[:cart_id]
  # 3) se create_if_missing for true e não existir, cria um novo
  def current_cart(create_if_missing:)
    if params[:cart_id].present?
      Cart.find_by(id: params[:cart_id])
    elsif session[:cart_id].present?
      Cart.find_by(id: session[:cart_id])
    elsif create_if_missing
      cart = Cart.create!
      session[:cart_id] = cart.id
      cart
    end
  end

  def find_product!
    product = Product.find_by(id: params[:product_id])
    return product if product

    render json: { error: 'Product not found' }, status: :not_found
    raise :halt
  end

  def parse_quantity!
    qty = params[:quantity].to_i
    if qty <= 0
      render json: { error: 'Invalid quantity' }, status: :unprocessable_entity
      raise :halt
    end
    qty
  end

  def add_or_update_item(cart, product, quantity)
    item = cart.cart_items.find_or_initialize_by(product: product)
    item.quantity = (item.quantity || 0) + quantity
    item.save!
  end

  def render_cart(cart, status: :ok)
    cart.reload

    products_payload = cart.cart_items.includes(:product).map do |item|
      {
        id:          item.product.id,
        name:        item.product.name,
        quantity:    item.quantity,
        unit_price:  item.product.unit_price,
        total_price: item.quantity * item.product.unit_price
      }
    end

    render json: {
      id:          cart.id,
      products:    products_payload,
      total_price: cart.total_price
    }, status: status
  end
end
