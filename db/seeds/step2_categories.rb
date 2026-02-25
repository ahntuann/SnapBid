# db/seeds/step2_categories.rb
puts "== Creating sample categories =="

categories = [
  { name: "Áo" },
  { name: "Quần" },
  { name: "Giày" },
  { name: "Dép" },
  { name: "Phụ kiện" },
  { name: "Túi xách" },
  { name: "Adidas" },
  { name: "Dior" },
  { name: "Chanel" },
  { name: "Nike" },
  { name: "Gucci" }
]

categories.each do |cat_attrs|
  category = Category.find_or_create_by(name: cat_attrs[:name]) do |cat|
    cat.name = cat_attrs[:name]
  end
  
  puts "Created category: #{category.name}"
end

puts "== Done creating categories =="