class StockMovement < ApplicationRecord
  belongs_to :product, optional: false
  belongs_to :user, optional: false

  validates :movement,
    numericality: {
      only_integer: true,
      other_than: 0
    }, presence: true
end
