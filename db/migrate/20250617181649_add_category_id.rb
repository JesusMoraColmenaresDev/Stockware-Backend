class AddCategoryId < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :category_id, :int
    remove_column :products, :category, :string
  end
end
