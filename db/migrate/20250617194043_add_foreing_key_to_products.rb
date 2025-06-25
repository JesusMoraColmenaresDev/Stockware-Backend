class AddForeingKeyToProducts < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :products, :categories, column: :category_id
  end
end
