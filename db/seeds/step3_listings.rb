# db/seeds/step3_listings.rb
require 'faker'

puts "== Creating sample listings =="

# Get users
admin = User.find_by(email: "admin@test.com") || User.first
seller = User.find_by(email: "seller@test.com") || User.second
buyer1 = User.find_by(email: "buyer1@test.com")
buyer2 = User.find_by(email: "buyer2@test.com")

# Get some categories
categories = Category.limit(5).pluck(:name)

# Create sample listings
sample_listings = [
  {
    title: "iPhone 13 Pro Max 256GB",
    category: categories.sample,
    condition: "new",
    start_price: 25000000,
    bid_increment: 100000,
    buy_now_price: 28000000,
    auction_ends_at: 3.days.from_now
  },
  {
    title: "MacBook Air M2 2023",
    category: categories.sample,
    condition: "like_new",
    start_price: 30000000,
    bid_increment: 200000,
    buy_now_price: 35000000,
    auction_ends_at: 2.days.from_now
  },
  {
    title: "Áo khoác da cao cấp",
    category: categories.sample,
    condition: "good",
    start_price: 1500000,
    bid_increment: 50000,
    buy_now_price: 2000000,
    auction_ends_at: 5.days.from_now
  },
  {
    title: "Samsung Galaxy S23 Ultra",
    category: categories.sample,
    condition: "new",
    start_price: 22000000,
    bid_increment: 100000,
    buy_now_price: 26000000,
    auction_ends_at: 4.days.from_now
  },
  {
    title: "Đồng hồ Rolex Datejust",
    category: categories.sample,
    condition: "excellent",
    start_price: 50000000,
    bid_increment: 500000,
    buy_now_price: 60000000,
    auction_ends_at: 7.days.from_now
  },
  {
    title: "Máy ảnh Canon EOS R5",
    category: categories.sample,
    condition: "good",
    start_price: 40000000,
    bid_increment: 200000,
    buy_now_price: 45000000,
    auction_ends_at: 6.days.from_now
  },
  {
    title: "Tai nghe Sony WH-1000XM4",
    category: categories.sample,
    condition: "new",
    start_price: 8000000,
    bid_increment: 100000,
    buy_now_price: 10000000,
    auction_ends_at: 2.days.from_now
  },
  {
    title: "Laptop Dell XPS 13",
    category: categories.sample,
    condition: "like_new",
    start_price: 18000000,
    bid_increment: 100000,
    buy_now_price: 22000000,
    auction_ends_at: 3.days.from_now
  }
]

sample_listings.each do |attrs|
  listing = Listing.find_or_create_by(title: attrs[:title], user: seller) do |l|
    l.title = attrs[:title]
    l.category = attrs[:category]
    l.condition = attrs[:condition]
    l.seller_note = Faker::Lorem.paragraph(sentence_count: 2)
    l.start_price = attrs[:start_price]
    l.bid_increment = attrs[:bid_increment]
    l.buy_now_price = attrs[:buy_now_price]
    l.auction_ends_at = attrs[:auction_ends_at]
    l.status = :published
    l.published_at = Time.current
  end
  
  puts "Created listing: #{listing.title}"
end

puts "== Done creating listings =="