class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :cost_price, precision: 10, scale: 2
      t.integer :stock, null: false, default: 0
            
      t.timestamps
    end
  end
end