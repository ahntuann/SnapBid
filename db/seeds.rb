# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing seeds if needed
# User.where.not(email: ['admin@example.com']).delete_all

puts "Starting seed process..."

# Run all seed files in order
Dir[Rails.root.join('db', 'seeds', '*.rb')].sort.each do |seed_file|
  puts "Running seed: #{File.basename(seed_file)}"
  load(seed_file)
end

puts "Seeding completed!"

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# SystemSetting.first_or_create!(
#   ai_threshold: 0.85,
#   commission_percent: 5.0,
#   min_bid_step: 10.0
# )

# User.find_or_create_by!(email: "admin@snapbid.local") do |u|
#   u.name = "Admin"
#   u.role = :admin
#   u.password = "admin123456"
#   u.email_verified_at = Time.current
# end

# User.find_or_create_by!(email: "cs@snapbid.local") do |u|
#   u.name = "Customer Support"
#   u.role = :cs
#   u.password = "cs123456"
#   u.email_verified_at = Time.current
# end


%w[Thời\ trang Túi\ sách Điện\ tử Đồ\ thủ\ công Tranh-ảnh Đồ\ gỗ Khác].each do |name|
  Category.find_or_create_by!(name: name)
end