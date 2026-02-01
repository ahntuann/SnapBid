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

["buyer1@test.com", "buyer2@test.com", "buyer3@test.com"].each_with_index do |email, idx|
  buyer = upsert_user!(email: email, name: "Buyer #{idx+1}", role: :user)
  puts "Created/Updated buyer user: #{buyer.email}"
end

puts "== Done creating users =="
