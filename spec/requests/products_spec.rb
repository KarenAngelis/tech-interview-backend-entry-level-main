require 'rails_helper'

RSpec.describe "/products", type: :request do
  # =========================================================================
  # 🔑 CORREÇÃO: Definindo atributos válidos e inválidos no escopo principal
  # Usando os nomes de coluna do seu Schema: unit_price, cost_price, stock
  # =========================================================================
  let(:valid_attributes) {
    {
      name: 'Test Product Name',
      unit_price: 15.00,
      cost_price: 10.00,
      stock: 50
    }
  }

  let(:invalid_attributes) {
    {
      name: nil,          # Nome é null: inválido
      unit_price: -5.00,  # Preço negativo: inválido (se a validação for > 0)
      cost_price: 10.00,
      stock: 50
    }
  }

  let(:valid_headers) {
    {}
  }

  # ------------------------------------------------------------------------
  
  describe "GET /index" do
    it "renders a successful response" do
      Product.create! valid_attributes
      get products_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      product = Product.create! valid_attributes
      get product_url(product), as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Product" do
        expect {
          post products_url,
               params: { product: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Product, :count).by(1)
      end

      it "renders a JSON response with the new product" do
        post products_url,
             params: { product: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Product" do
        expect {
          post products_url,
               params: { product: invalid_attributes }, as: :json
        }.to change(Product, :count).by(0)
      end

      it "renders a JSON response with errors for the new product" do
        post products_url,
             params: { product: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /update" do
    # 🔑 CORREÇÃO: Definindo os atributos de atualização (new_attributes) aqui,
    # onde eles serão necessários para os testes de update.
    let(:new_name) { 'New Updated Name' }
    let(:new_unit_price) { 20.00 }
    let(:new_attributes) {
      {
        name: new_name,
        unit_price: new_unit_price,
        cost_price: 12.00 # Apenas para garantir que o campo não seja nulo
      }
    }

    context "with valid parameters" do
      it "updates the requested product" do
        product = Product.create! valid_attributes
        patch product_url(product),
              params: { product: new_attributes }, headers: valid_headers, as: :json
        product.reload
        expect(product.name).to eq(new_name)
        expect(product.unit_price).to eq(new_unit_price) # Corrigido: usando unit_price
      end

      it "renders a JSON response with the product" do
        product = Product.create! valid_attributes
        patch product_url(product),
              params: { product: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the product" do
        product = Product.create! valid_attributes
        patch product_url(product),
              params: { product: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested product" do
      product = Product.create! valid_attributes
      expect {
        delete product_url(product), headers: valid_headers, as: :json
      }.to change(Product, :count).by(-1)
    end
  end
end