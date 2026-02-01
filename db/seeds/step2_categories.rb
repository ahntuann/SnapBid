# db/seeds/step2_categories.rb
puts "== Creating sample categories =="

categories = [
  { name: "Điện thoại & Máy tính bảng" },
  { name: "Thời trang nam" },
  { name: "Thời trang nữ" },
  { name: "Đồng hồ & Trang sức" },
  { name: "Thiết bị điện tử" },
  { name: "Sức khỏe & Sắc đẹp" },
  { name: "Nhà cửa & Đời sống" },
  { name: "Mẹ & Bé" },
  { name: "Thể thao & Du lịch" },
  { name: "Xe cộ" },
  { name: "Khác" }
]

categories.each do |cat_attrs|
  category = Category.find_or_create_by(name: cat_attrs[:name]) do |cat|
    cat.name = cat_attrs[:name]
  end
  
  puts "Created category: #{category.name}"
end

puts "== Done creating categories =="