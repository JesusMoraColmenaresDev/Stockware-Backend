class AddMinimumQuantityToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :minimumQuantity, :integer, default: 1, null: false
  end
end
