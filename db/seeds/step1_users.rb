# db/seeds/step1_users.rb
puts "== Creating sample users =="

def upsert_user!(email:, name:, role:, password: "password123")
  u = User.find_or_initialize_by(email: email)
  u.name = name
  u.role = role
  u.password = password
  u.password_confirmation = password
  u.email_verified_at ||= Time.current
  u.save!  # <-- fail là nổ lỗi ngay
  u
end

admin = upsert_user!(email: "admin@test.com",  name: "Admin User", role: :admin)
puts "Created/Updated admin user: #{admin.email}"

cs_user = upsert_user!(email: "cs@test.com", name: "CS User", role: :cs)
puts "Created/Updated CS user: #{cs_user.email}"

seller = upsert_user!(email: "seller@test.com", name: "Seller User", role: :user)
puts "Created/Updated seller user: #{seller.email}"

# buyer1 → Nguyễn Thị Thanh Hà
upsert_user!(email: "thanhha1990@gmail.com",  name: "Nguyễn Thị Thanh Hà", role: :user).tap { |u| puts "Created/Updated: #{u.email}" }
# buyer2 → Trần Minh Quân
upsert_user!(email: "minhquan557@gmail.com",  name: "Trần Minh Quân",       role: :user).tap { |u| puts "Created/Updated: #{u.email}" }
# buyer3 → Lê Phương Linh
upsert_user!(email: "linhlinh98@gmail.com",   name: "Lê Phương Linh",      role: :user).tap { |u| puts "Created/Updated: #{u.email}" }
# buyer4 → Hoàng Văn Đức
upsert_user!(email: "vanduc.hvd@gmail.com",   name: "Hoàng Văn Đức",       role: :user).tap { |u| puts "Created/Updated: #{u.email}" }
# buyer5 → Phạm Thị Nga
upsert_user!(email: "ngapham2001@gmail.com",  name: "Phạm Thị Nga",        role: :user).tap { |u| puts "Created/Updated: #{u.email}" }

test_user1 = upsert_user!(email: "huongngo88@gmail.com",  name: "Ngô Thị Hương", role: :user)
test_user1.update!(snapbid_coins: 900)
puts "Created/Updated test user 1: #{test_user1.email}"

test_user2 = upsert_user!(email: "tuanbv2005@gmail.com",  name: "Bùi Văn Tuấn",  role: :user)
test_user2.update!(snapbid_coins: 900)
puts "Created/Updated test user 2: #{test_user2.email}"

puts "== Done creating users =="
