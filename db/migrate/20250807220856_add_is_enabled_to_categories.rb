class AddIsEnabledToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :is_enabled, :boolean, default: true, null: false
    add_index :categories, :is_enabled
  end
end
