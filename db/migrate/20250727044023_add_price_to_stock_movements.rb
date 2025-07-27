class AddPriceToStockMovements < ActiveRecord::Migration[8.0]
  def change
    add_column :stock_movements, :price, :decimal,
      precision: 10, scale: 2,
      null: false, default: 0.0
  end
end
