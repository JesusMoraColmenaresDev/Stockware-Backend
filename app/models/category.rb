class Category < ApplicationRecord
  has_many :products, dependent: :restrict_with_error
end
