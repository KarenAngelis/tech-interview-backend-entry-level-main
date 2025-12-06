class AddCostPriceAndStockToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :cost_price, :decimal, precision: 10, scale: 2
    add_column :products, :stock, :integer
  end
end
