class Product < ApplicationRecord
    # Esto de optional es para que de una vez verifique si si hay una categoria asociada al category id que le pasemos
    belongs_to :category, optional: false, counter_cache: true
    validates :name, presence: true
    validates :price, presence: true
    validates :category_id, presence: true
    validates :description, presence: true
    validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :price, numericality: { greater_than: 0 }
    validates :category_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :minimumQuantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

    has_one_attached :image

    def image_url
        if image.attached?
            Rails.application.routes.url_helpers.url_for(image)
        end
    end
end
