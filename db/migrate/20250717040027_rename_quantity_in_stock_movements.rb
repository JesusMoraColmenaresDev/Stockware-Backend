class RenameQuantityInStockMovements < ActiveRecord::Migration[8.0]
  def change
    rename_column :stock_movements, :quantity, :movement
  end
end
