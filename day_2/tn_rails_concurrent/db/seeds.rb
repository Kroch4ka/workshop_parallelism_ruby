Order.destroy_all
puts "Orders destroyed"
Product.destroy_all
puts "Products destroyed"

Product.insert_all(Array.new(100_000) { { name: "Product #{rand(1..100_000_000)}", stock: rand(1..50_00), price: rand(10..100_000) } })
puts "Products created: #{Product.count}"

product_ids = Product.pluck(:id)
statuses = ["pending", "processed", "cancelled"]
dates = (1..30).map { |n| n.days.ago }
ActiveRecord::Base.record_timestamps = false
Order.insert_all(Array.new(100_000_000) {
  {
    product_id: product_ids.sample, quantity: rand(1..10),
    current_status: statuses.sample,
    created_at: dates.sample,
    updated_at: dates.sample,
  }
})
ActiveRecord::Base.record_timestamps = true
puts "Orders created: #{Order.count}"
