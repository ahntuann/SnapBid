seller = User.find_by(email: "seller@test.com") ||
         User.first

def create_listing(attrs)
  Listing.create!(
    {
      title: attrs[:title],
      category: "test",
      condition: "good",
      seller_note: "Seed data for step 10 testing-p2",
      user: attrs[:user],
      status: :published,
      published_at: Time.current
    }.merge(attrs.except(:title, :user))
  )
end

puts "== Seeding Step 10 listings =="

# A. Auction open
# create_listing(
#   title: "Auction Only - Open-3",
#   user: seller,
#   start_price: 1000,
#   bid_increment: 100,
#   auction_ends_at: 2.days.from_now
# )

# B. Auction + Buy Now
create_listing(
  title: "Auction + Buy Now - 3min-2",
  user: seller,
  start_price: 2000,
  bid_increment: 200,
  buy_now_price: 5000,
  auction_ends_at: Time.current + 2.minutes
)

# create_listing(
#   title: "Auction + Buy Now - 2min-2",
#   user: seller,
#   start_price: 2000,
#   bid_increment: 200,
#   buy_now_price: 5000,
#   auction_ends_at: Time.current + 1.minutes
# )

# create_listing(
#   title: "Auction + Buy Now-13",
#   user: seller,
#   start_price: 2000,
#   bid_increment: 200,
#   buy_now_price: 5000,
#   auction_ends_at: 2.days.from_now
# )

# create_listing(
#   title: "Auction + Buy Now-14",
#   user: seller,
#   start_price: 2000,
#   bid_increment: 200,
#   buy_now_price: 5000,
#   auction_ends_at: 2.days.from_now
# )

# create_listing(
#   title: "Auction + Buy Now-15",
#   user: seller,
#   start_price: 2000,
#   bid_increment: 200,
#   buy_now_price: 5000,
#   auction_ends_at: 2.days.from_now
# )

# create_listing(
#   title: "Auction + Buy Now-16",
#   user: seller,
#   start_price: 2000,
#   bid_increment: 200,
#   buy_now_price: 5000,
#   auction_ends_at: 2.days.from_now
# )

# create_listing(
#   title: "Auction + Buy Now-17",
#   user: seller,
#   start_price: 2000,
#   bid_increment: 200,
#   buy_now_price: 5000,
#   auction_ends_at: 2.days.from_now
# )

# create_listing(
#   title: "Auction + Buy Now-18",
#   user: seller,
#   start_price: 2000,
#   bid_increment: 200,
#   buy_now_price: 5000,
#   auction_ends_at: 2.days.from_now
# )

# create_listing(
#   title: "Auction + Buy Now-19",
#   user: seller,
#   start_price: 2000,
#   bid_increment: 200,
#   buy_now_price: 5000,
#   auction_ends_at: 2.days.from_now
# )

# create_listing(
#   title: "Auction + Buy Now-19",
#   user: seller,
#   start_price: 2000,
#   bid_increment: 200,
#   buy_now_price: 5000,
#   auction_ends_at: 2.days.from_now
# )

# C. Auction ended
# create_listing(
#   title: "Auction Ended-3",
#   user: seller,
#   start_price: 1000,
#   bid_increment: 100,
#   buy_now_price: 3000,
#   auction_ends_at: 1.day.ago
# )

# # D. Buy Now only
# create_listing(
#   title: "Buy Now Only-3",
#   user: seller,
#   buy_now_price: 4000
# )

# # E. Not published
# Listing.create!(
#   title: "Draft Listing-3",
#   category: "test",
#   condition: "new",
#   seller_note: "Not published yet",
#   user: seller,
#   status: :draft,
#   start_price: 1000,
#   auction_ends_at: 2.days.from_now
# )

puts "== Done =="
