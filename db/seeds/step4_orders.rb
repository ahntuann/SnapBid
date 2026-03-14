# db/seeds/step4_orders.rb
# Tạo 3 đơn hàng mô phỏng: giày lười Vero Cuoio 800k, áo Global Work 290k, mũ bere 250k

puts "== Creating sample orders =="

seller = User.find_by(email: "seller@test.com") || User.where(is_seller: true).first || User.first

# Người mua / người đấu giá (10 user tổng: admin, cs, seller, 5 buyers, test1, test2)
buyer1 = User.find_by(email: "thanhha1990@gmail.com")
buyer2 = User.find_by(email: "minhquan557@gmail.com")
buyer3 = User.find_by(email: "linhlinh98@gmail.com")
buyer4 = User.find_by(email: "vanduc.hvd@gmail.com")
buyer5 = User.find_by(email: "ngapham2001@gmail.com")
test1  = User.find_by(email: "huongngo88@gmail.com")

categories = Category.limit(3).to_a

# ── Listing 1: Giày lười Vero Cuoio → Order 800k (paid) ─── 3 người, 6 lượt ──
# buyer2 & buyer3 đua nhau, buyer1 vào muộn thắng ở 800k
listing1 = Listing.find_or_create_by!(title: "Giày lười Vero Cuoio", user: seller) do |l|
  l.category         = categories[0]
  l.condition        = "like_new"
  l.seller_note      = "Giày lười da bò Vero Cuoio nhập khẩu Ý, size 41, mặc 3 lần. Đế cao su chắc chắn, đế trong sạch sẽ."
  l.start_price      = 500_000
  l.bid_increment    = 50_000
  l.buy_now_price    = 1_000_000
  l.auction_ends_at  = 3.days.ago
  l.status           = :published
  l.published_at     = 6.days.ago
end

unless listing1.bids.exists?
  Bid.insert_all([
    { listing_id: listing1.id, user_id: buyer2.id, amount: 550_000, created_at: 6.days.ago + 3.hours, updated_at: 6.days.ago + 3.hours },
    { listing_id: listing1.id, user_id: buyer3.id, amount: 600_000, created_at: 6.days.ago + 5.hours, updated_at: 6.days.ago + 5.hours },
    { listing_id: listing1.id, user_id: buyer2.id, amount: 650_000, created_at: 5.days.ago + 1.hour,  updated_at: 5.days.ago + 1.hour  },
    { listing_id: listing1.id, user_id: buyer3.id, amount: 700_000, created_at: 5.days.ago + 4.hours, updated_at: 5.days.ago + 4.hours },
    { listing_id: listing1.id, user_id: buyer2.id, amount: 750_000, created_at: 4.days.ago + 2.hours, updated_at: 4.days.ago + 2.hours },
    { listing_id: listing1.id, user_id: buyer1.id, amount: 800_000, created_at: 3.days.ago + 1.hour,  updated_at: 3.days.ago + 1.hour  },
  ])
  puts "  Seeded #{listing1.bids.count} bids for listing1"
end

order1 = Order.find_or_initialize_by(listing: listing1)
unless order1.persisted?
  order1.buyer                   = buyer1
  order1.price                   = 800_000
  order1.total                   = 800_000
  order1.kind                    = :auction_win
  order1.status                  = :paid
  order1.buyer_marked_paid_at    = 2.days.ago
  order1.admin_confirmed_paid_at = 1.day.ago
  order1.recipient_name          = "Nguyễn Thị Thanh Hà"
  order1.recipient_phone         = "0976 543 210"
  order1.shipping_address        = "58 Hàng Bông, Hoàn Kiếm, Hà Nội"
  order1.save!
  order1.update_column(:sepay_ref, "SNAPBID#{order1.id}")
  puts "  Created order ##{order1.id} - Giày lười Vero Cuoio 800,000đ (paid) - #{order1.recipient_name}"
else
  puts "  Order Vero Cuoio already exists (##{order1.id})"
end

# ── Listing 2: Áo sơ mi dài tay Global Work → Order 350k (paid) ─── 6 người, 10 lượt ──
# buyer1,3,4,5,test1 đua nhau, buyer2 vào thắng ở lượt cuối
listing2 = Listing.find_or_create_by!(title: "Áo sơ mi dài tay Global Work", user: seller) do |l|
  l.category         = categories[1] || categories[0]
  l.condition        = "good"
  l.seller_note      = "Áo sơ mi dài tay thương hiệu Global Work (Nhật), size M, màu xanh nhạt. Vải cotton pha linen mát, còn khoảng 90%."
  l.start_price      = 150_000
  l.bid_increment    = 20_000
  l.buy_now_price    = 400_000
  l.auction_ends_at  = 1.day.ago
  l.status           = :published
  l.published_at     = 5.days.ago
end

unless listing2.bids.exists?
  Bid.insert_all([
    { listing_id: listing2.id, user_id: buyer1.id, amount: 170_000, created_at: 5.days.ago + 2.hours, updated_at: 5.days.ago + 2.hours },
    { listing_id: listing2.id, user_id: buyer3.id, amount: 190_000, created_at: 4.days.ago + 5.hours, updated_at: 4.days.ago + 5.hours },
    { listing_id: listing2.id, user_id: buyer4.id, amount: 210_000, created_at: 4.days.ago + 8.hours, updated_at: 4.days.ago + 8.hours },
    { listing_id: listing2.id, user_id: buyer5.id, amount: 230_000, created_at: 3.days.ago + 2.hours, updated_at: 3.days.ago + 2.hours },
    { listing_id: listing2.id, user_id: test1.id,  amount: 250_000, created_at: 3.days.ago + 6.hours, updated_at: 3.days.ago + 6.hours },
    { listing_id: listing2.id, user_id: buyer1.id, amount: 270_000, created_at: 2.days.ago + 3.hours, updated_at: 2.days.ago + 3.hours },
    { listing_id: listing2.id, user_id: buyer3.id, amount: 290_000, created_at: 2.days.ago + 7.hours, updated_at: 2.days.ago + 7.hours },
    { listing_id: listing2.id, user_id: buyer4.id, amount: 310_000, created_at: 1.day.ago + 2.hours,  updated_at: 1.day.ago + 2.hours  },
    { listing_id: listing2.id, user_id: buyer5.id, amount: 330_000, created_at: 1.day.ago + 6.hours,  updated_at: 1.day.ago + 6.hours  },
    { listing_id: listing2.id, user_id: buyer2.id, amount: 350_000, created_at: 1.day.ago + 10.hours, updated_at: 1.day.ago + 10.hours },
  ])
  puts "  Seeded #{listing2.bids.count} bids for listing2"
end

order2 = Order.find_or_initialize_by(listing: listing2)
unless order2.persisted?
  order2.buyer                   = buyer2
  order2.price                   = 350_000
  order2.total                   = 350_000
  order2.kind                    = :auction_win
  order2.status                  = :paid
  order2.buyer_marked_paid_at    = 10.hours.ago
  order2.admin_confirmed_paid_at = 2.hours.ago
  order2.recipient_name          = "Trần Minh Quân"
  order2.recipient_phone         = "0912 876 543"
  order2.shipping_address        = "14 Đội Cấn, Ba Đình, Hà Nội"
  order2.save!
  order2.update_column(:sepay_ref, "SNAPBID#{order2.id}")
  puts "  Created order ##{order2.id} - Áo sơ mi Global Work 290,000đ (paid) - #{order2.recipient_name}"
else
  puts "  Order Global Work already exists (##{order2.id})"
end

# ── Listing 3: Mũ bere noname → Order 250k (paid) ─── 5 người, 9 lượt ────────
# buyer1,2,4,5 đua, buyer3 vào thắng ở lượt cuối 250k
listing3 = Listing.find_or_create_by!(title: "Mũ bere noname", user: seller) do |l|
  l.category         = categories[2] || categories[0]
  l.condition        = "good"
  l.seller_note      = "Mũ bere len dày không thương hiệu, màu đen, size free. Mới mua dùng vài lần, form chuẩn."
  l.start_price      = 100_000
  l.bid_increment    = 10_000
  l.buy_now_price    = 350_000
  l.auction_ends_at  = 12.hours.ago
  l.status           = :published
  l.published_at     = 4.days.ago
end

unless listing3.bids.exists?
  Bid.insert_all([
    { listing_id: listing3.id, user_id: buyer1.id, amount: 110_000, created_at: 4.days.ago + 1.hour,  updated_at: 4.days.ago + 1.hour  },
    { listing_id: listing3.id, user_id: buyer2.id, amount: 130_000, created_at: 4.days.ago + 3.hours, updated_at: 4.days.ago + 3.hours },
    { listing_id: listing3.id, user_id: buyer4.id, amount: 150_000, created_at: 3.days.ago + 2.hours, updated_at: 3.days.ago + 2.hours },
    { listing_id: listing3.id, user_id: buyer5.id, amount: 170_000, created_at: 3.days.ago + 5.hours, updated_at: 3.days.ago + 5.hours },
    { listing_id: listing3.id, user_id: buyer1.id, amount: 190_000, created_at: 2.days.ago + 2.hours, updated_at: 2.days.ago + 2.hours },
    { listing_id: listing3.id, user_id: buyer2.id, amount: 210_000, created_at: 2.days.ago + 5.hours, updated_at: 2.days.ago + 5.hours },
    { listing_id: listing3.id, user_id: buyer4.id, amount: 225_000, created_at: 1.day.ago + 2.hours,  updated_at: 1.day.ago + 2.hours  },
    { listing_id: listing3.id, user_id: buyer5.id, amount: 240_000, created_at: 1.day.ago + 6.hours,  updated_at: 1.day.ago + 6.hours  },
    { listing_id: listing3.id, user_id: buyer3.id, amount: 250_000, created_at: 13.hours.ago,          updated_at: 13.hours.ago          },
  ])
  puts "  Seeded #{listing3.bids.count} bids for listing3"
end

order3 = Order.find_or_initialize_by(listing: listing3)
unless order3.persisted?
  order3.buyer                   = buyer3
  order3.price                   = 250_000
  order3.total                   = 250_000
  order3.kind                    = :auction_win
  order3.status                  = :paid
  order3.buyer_marked_paid_at    = 6.hours.ago
  order3.admin_confirmed_paid_at = 1.hour.ago
  order3.recipient_name          = "Lê Phương Linh"
  order3.recipient_phone         = "0934 112 789"
  order3.shipping_address        = "32 Khâm Thiên, Đống Đa, Hà Nội"
  order3.save!
  order3.update_column(:sepay_ref, "SNAPBID#{order3.id}")
  puts "  Created order ##{order3.id} - Mũ bere noname 250,000đ (paid) - #{order3.recipient_name}"
else
  puts "  Order mũ bere already exists (##{order3.id})"
end

puts "== Done creating sample orders =="
