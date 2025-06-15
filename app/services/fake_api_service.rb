require 'httparty'
require 'json'
require 'down'

class FakeApiService
  URL = "https://fakestoreapi.com/products"
  
  def self.get_products
    response = HTTParty.get(URL)
    if response.success?
      products = response.parsed_response

      products.each do |product_data|
        product = Product.new(
          name: product_data["title"],
          price: product_data['price'],
          description: product_data["description"],
          category: product_data["category"]
        )

        if product_data['image'].present?
          begin
            tempfile = Down.download(product_data['image'])
            
            product.image.attach(
              io: tempfile,  # Corregido: espacio después de :
              filename: "product_#{SecureRandom.hex(8)}.jpg",
              content_type: 'image/jpeg'
            )
          rescue Down::Error => e
            puts "Error imagen: #{e.message} - Producto: #{product_data['title']}"
          end
        end

        if product.save
          puts "producto guardado"
        else
          puts "error guardando el producto"
        end
      end
    else
      puts "Error: #{response.code} #{response.message}" 
    end
  end
end