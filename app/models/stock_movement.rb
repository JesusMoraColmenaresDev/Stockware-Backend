class StockMovement < ApplicationRecord
  belongs_to :product, optional: false
  belongs_to :user, optional: false

  validates :movement,
    numericality: {
      only_integer: true,
      other_than: 0
    }, presence: true

  # whenever someone calls `to_json` / `as_json` on a movement,
  # force the price back into a Ruby Float
  def as_json(options = {})
    super(options).merge("price" => price.to_f)
  end
end
