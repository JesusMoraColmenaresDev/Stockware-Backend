class StockMovement < ApplicationRecord
  belongs_to :product, optional: false
  belongs_to :user, optional: false

  validates :quantity,
    numericality: {
      only_integer: true,
      other_than: 0
    }, presence: true
end
