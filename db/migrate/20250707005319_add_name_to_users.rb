class AddNameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string, null: false, default: "Unkown User"
  end
end
