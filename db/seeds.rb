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
  cat = Category.create!(name: raw_name.capitalize, is_enabled: true)
  categories_map[raw_name] = cat.id
  puts "  • #{cat.name} (##{cat.id}) [enabled=#{cat.is_enabled}]"
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

35.times do
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




puts "✅ Basic Seeding complete!, now we just create random data to fill up to 31 records each."






# LLenar de datos Random
# ────────────
# Ensure at least 31 Categories
# ────────────
while Category.count < 31 # Como entramos usando el Columna.count, empezamos a llenar directamente despues del ultimo valor de la Columna
  Category.create!(
    name: "ExtraCategory#{Category.count + 1}",
    # Create some disabled categories for testing purposes
    is_enabled: true # [true, true, false].sample
  )
end

puts "✅ Created #{Category.count} categories."

# ────────────
# Ensure at least 31 Products (with random fox images)
# ────────────
while Product.count < 31
  proto = Product.all.sample
  dup   = proto.dup
  dup.name             = "#{proto.name} (Copy #{Product.count + 1})"
  dup.stock            = rand(10..100)
  dup.minimumQuantity  = rand(1..5)
  dup.is_enabled       = true # [ true, false ].sample
  dup.save!

  # fetch a random fox image and attach
  begin
    resp = Net::HTTP.get_response(URI("https://randomfox.ca/floof/"))
    if resp.is_a?(Net::HTTPSuccess)
      image_url = JSON.parse(resp.body)["image"]
      dup.image.attach(
        io:           URI.open(image_url),
        filename:     File.basename(URI.parse(image_url).path),
        content_type: "image/jpeg"
      )
    end
  rescue => e
    warn "    ! failed to attach fox image: #{e.message}"
  end
end

puts "✅ Created #{Product.count} products."

# ────────────
# Ensure at least 31 Users
# ────────────
while User.count < 31
  idx = User.count + 1
  User.create!(
    email:      "user#{idx}@example.com",
    password:   "pass_#{SecureRandom.hex(4)}",
    name:       "User#{idx}",
    role:       (idx % 10 == 0 ? "admin" : "user"),
    is_enabled: true # [ true, false ].sample
  )
end

puts "✅ Created #{User.count} users."

# ────────────
# Ensure at least 31 StockMovements
# ────────────
while StockMovement.count < 31
  product = Product.all.sample
  user    = User.all.sample
  qty     = ((1..10).to_a + (-10..-1).to_a).sample
  StockMovement.create!(
    product:  product,
    user:     user,
    movement: qty,
    price:    product.price
  )
end

puts "✅ Created #{StockMovement.count} stock movements."

puts "✅ Forced counts to at least 31 of each controllable model!"
puts "✅ Seeding complete!"
