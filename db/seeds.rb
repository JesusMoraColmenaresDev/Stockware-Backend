# run rails db:seed:replant




# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require "net/http"
require "json"
require "open-uri"

# Product.destroy_all
# Category.destroy_all
# User.destroy_all
# StockMovement.destroy_all

# # reset every table’s PK sequence (Postgres/SQLite only):
# [ Product, Category, User, StockMovement ].each do |model|
#   ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
# end


ActiveRecord::Base.connection.execute <<-SQL.squish
  TRUNCATE TABLE
    stock_movements,
    products,
    categories,
    users
  RESTART IDENTITY
  CASCADE;
SQL

puts "Fetching data from API..."

def obtenerCategorias
  uri = URI("https://fakestoreapi.com/products/categories")
  response = Net::HTTP.get_response(uri)

  if response.code == '200'
    JSON.parse(response.body)
  else
    puts "Fallo al obtener las Categorias: #{response.code}"
    []
  end
end

def obtenerProductos
  uri = URI('https://fakestoreapi.com/products')
  response = Net::HTTP.get_response(uri)

  if response.code == '200'
    JSON.parse(response.body)
  else
    puts "Fallo al obtener los Productos:: #{response.code}"
    []
  end
end



puts "Creando Categorias . . ."
categorias_api = obtenerCategorias
categorias_map = {}

categorias_api.each do |c|
  categoria = Category.create!(name: c.capitalize) # No hay NADA mas en ese Json, solo 1 dato por c/u
  categorias_map[c] = categoria.id
  puts "Categoria #{categoria.name} Creada"
end


puts "Creando Productos . . ."
productos_api = obtenerProductos

productos_api.each do |data|
  # Mapear la Categoria al Producto
  id_Categoria = categorias_map[data['category']] || categorias_map.values.first # Ni idea de eso del final

  producto = Product.create!(
    name: data['title'],
    price: data['price'],
    category_id: id_Categoria,
    description: data['description'],
    stock: rand(10..100), # La APi no da Stock, tons Random
    minimumQuantity: rand(1..5)
  )

  if data['image'].present?
    begin
      producto.image.attach(
        io: URI.open(data['image']),
        filename: "#{data['title'].parameterize}.jpg",
        content_type: 'image/jpeg'
      )
      puts "Imagen Agregada"
    rescue => e
      puts "Error Al Agregar Imagen #{e.message}"
    end
  end
end

puts "Creando usuarios . . ."
users = [
  { email: 'Jesus@gmail.com', password: '1234_5678', name: "Jesus", role: "admin", is_enabled: true },
  { email: 'Pob@gmail.com',   password: '1234_5678', name: "Pob", is_enabled: true  },
  { email: 'user@gmail.com',  password: '1234_5678', name: "User", role: "admin", is_enabled: false }
]

users.each do |attrs|
  User.create!(attrs).tap do |u|
    puts "Created user ##{u.id} (#{u.email})"
  end
end


StockMovement.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('stock_movements')

puts "Seeding stock movements…"
products = Product.all.to_a
users    = User.all.to_a

5.times do
  product  = products.sample
  user     = users.sample
  # pick a random quantity between -10 and +10, excluding 0
  movement = ([ *1..10 ] + [ *-10..-1 ]).sample

  StockMovement.create!(
    product:  product,
    user:     user,
    movement: movement
  )

  puts "  • #{movement > 0 ? 'Added' : 'Removed'} #{movement.abs} units "\
    "on product ##{product.id} by user ##{user.id}"
end


# ActiveRecord::Base.connection.tables.each do |table|
#   ActiveRecord::Base.connection.reset_pk_sequence!(table)
# end

# Product.create!(
#   {
#     name: "monitor",
#     price: 12.0
#   }
# )
