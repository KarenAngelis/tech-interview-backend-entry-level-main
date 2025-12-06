class AddCustomerNameToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :customer_name, :string
  end
end
