class AddIsEnabledToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :is_enabled, :boolean, default: true, null: false
  end
end
