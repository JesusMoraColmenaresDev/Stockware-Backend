# run with: bin/rails db:seed:replant
require "fileutils"
require "net/http"
require "json"
require "open-uri"

# Truncate and reset all the tables we care about
ActiveRecord::Base.connection.execute <<-SQL.squish
  TRUNCATE TABLE
    stock_movements,
    products,
    categories,
    users
  RESTART IDENTITY
  CASCADE;
SQL

puts "Clearing ActiveStorage storage directory..."
storage_dir = Rails.root.join("storage")
if Dir.exist?(storage_dir)
  Dir.children(storage_dir).each do |entry|
    path = storage_dir.join(entry)
    FileUtils.rm_rf(path)
  end
end

puts "Fetching data from API..."

def fetch_categories
  uri = URI("https://fakestoreapi.com/products/categories")
  resp = Net::HTTP.get_response(uri)
  resp.code == "200" ? JSON.parse(resp.body) : []
end

def fetch_products
  uri = URI("https://fakestoreapi.com/products")
  resp = Net::HTTP.get_response(uri)
  resp.code == "200" ? JSON.parse(resp.body) : []
end

# ────────────
# Create Categories
# ────────────
puts "Creating categories…"
categories_api = fetch_categories
categories_map = {}

categories_api.each do |raw_name|
  cat = Category.create!(name: raw_name.capitalize)
  categories_map[raw_name] = cat.id
  puts "  • #{cat.name} (##{cat.id})"
end

# ────────────
# Create Products
# ────────────
puts "Creating products…"
fetch_products.each do |data|
  cat_id = categories_map[data["category"]] || categories_map.values.first

  product = Product.create!(
    name:            data["title"],
    price:           data["price"],
    description:     data["description"],
    category_id:     cat_id,
    stock:           rand(10..100),
    minimumQuantity: rand(1..5),
    is_enabled:      true                  # ← explicitly set enabled
  )

  if data["image"].present?
    begin
      product.image.attach(
        io:          URI.open(data["image"]),
        filename:    "#{product.name.parameterize}.jpg",
        content_type: "image/jpeg"
      )
    rescue => e
      warn "    ! failed to attach image: #{e.message}"
    end
  end

  puts "  ✓ #{product.name} (##{product.id})"
end

# ────────────
# Create Users
# ────────────
puts "Creating users…"
[
  { email: 'Jesus@gmail.com',  password: '1234_5678', name: "Jesus", role: "admin", is_enabled: true  },
  { email: 'Pob@gmail.com',    password: '1234_5678', name: "Pob",   is_enabled: true                   },
  { email: 'user@gmail.com',   password: '1234_5678', name: "User",  role: "admin", is_enabled: false }
].each do |attrs|
  u = User.create!(attrs)
  puts "  • #{u.email} (##{u.id}) [enabled=#{u.is_enabled}]"
end

# ────────────
# Create Stock Movements
# ────────────
puts "Seeding stock movements…"
products = Product.all.to_a
users    = User.all.to_a

5.times do
  product = products.sample
  user    = users.sample
  qty     = ((1..10).to_a + (-10..-1).to_a).sample

  # snapshot the current price into the movement:
  m = StockMovement.create!(
    product:  product,
    user:     user,
    movement: qty,
    price:    product.price               # ← store the price at this moment
  )

  action = qty.positive? ? "Added" : "Removed"
  puts "  • #{action} #{qty.abs} of Product##{product.id} by User##{user.id} @ $#{m.price}"
end

puts "✅ Seeding complete!"
