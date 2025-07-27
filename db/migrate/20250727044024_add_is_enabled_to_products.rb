class AddIsEnabledToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :is_enabled, :boolean,
                null: false, default: true

    # optional, for faster lookups if you’ll often filter by is_enabled
    add_index :products, :is_enabled
  end
end
