class CreateCarts < ActiveRecord::Migration[7.1]
  def change
    create_table :carts do |t|
      t.string :customer_name, null: false 
      t.datetime :last_interaction_at      
      t.timestamps
    end
  end
end