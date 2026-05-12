puts "Seeding database..."

# Admin user
admin = User.find_or_create_by!(email: "admin@sellerhub.com") do |u|
  u.name = "Platform Admin"
  u.role = :admin
  u.active = true
  u.password = "password123"
  u.password_confirmation = "password123"
end
puts "Admin: #{admin.email} / password123"

# Seller users
sellers_data = [
  { name: "Alice Johnson", email: "alice@techsales.com", company_name: "TechSales Inc", phone: "+1-555-0101" },
  { name: "Bob Martinez", email: "bob@bobshop.com", company_name: "Bob's Workshop", phone: "+1-555-0102" },
  { name: "Carol White", email: "carol@carolcraft.com", company_name: "Carol Craft Co", phone: "+1-555-0103" }
]

sellers = sellers_data.map do |data|
  seller = User.find_or_create_by!(email: data[:email]) do |u|
    u.name = data[:name]
    u.company_name = data[:company_name]
    u.phone = data[:phone]
    u.role = :seller
    u.active = true
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  puts "Seller: #{seller.email} / password123"
  seller
end

# Products for first seller
seller = sellers.first
products_data = [
  { name: "Web Development", description: "Full-stack web development services", price: 150.00, unit: "hr" },
  { name: "SEO Package", description: "Complete SEO optimization", price: 500.00, unit: "month" },
  { name: "Logo Design", description: "Custom logo design", price: 299.00, unit: "each" },
  { name: "Social Media Management", description: "Monthly social media management", price: 350.00, unit: "month" },
  { name: "Consultation", description: "1-hour consultation session", price: 100.00, unit: "hr" }
]

products = products_data.map do |data|
  seller.products.find_or_create_by!(name: data[:name]) do |p|
    p.description = data[:description]
    p.price = data[:price]
    p.unit = data[:unit]
    p.active = true
  end
end

# Customers for first seller
customers_data = [
  { name: "Acme Corp", email: "billing@acme.com", phone: "+1-555-2001", company_name: "Acme Corporation", address: "123 Main St, New York, NY 10001" },
  { name: "Globex Ltd", email: "accounts@globex.com", phone: "+1-555-2002", company_name: "Globex International", address: "456 Oak Ave, Los Angeles, CA 90001" },
  { name: "Initech LLC", email: "finance@initech.com", phone: "+1-555-2003", company_name: "Initech LLC", address: "789 Pine Rd, Chicago, IL 60601" },
  { name: "Sarah Connor", email: "sarah@sc.com", phone: "+1-555-2004", company_name: "SC Consulting" },
  { name: "Wayne Enterprises", email: "ap@wayneent.com", phone: "+1-555-2005", company_name: "Wayne Enterprises", address: "1 Wayne Tower, Gotham, NJ 07001" }
]

customers = customers_data.map do |data|
  seller.customers.find_or_create_by!(email: data[:email]) do |c|
    c.name = data[:name]
    c.phone = data[:phone]
    c.company_name = data[:company_name]
    c.address = data[:address]
    c.active = true
  end
end

# Orders with various statuses
statuses = [:paid, :paid, :paid, :confirmed, :pending, :draft, :cancelled]
customers.each_with_index do |customer, i|
  2.times do |j|
    order = seller.orders.create!(
      customer: customer,
      status: statuses[(i + j) % statuses.size],
      due_date: (j + 1).months.from_now,
      notes: "Order for #{customer.name}"
    )
    # Add 2-3 items per order
    rand(2..3).times do
      product = products.sample
      qty = rand(1..5)
      order.order_items.create!(
        product: product,
        description: product.name,
        quantity: qty,
        unit_price: product.price
      )
    end
    order.reload

    # Create invoice for paid/confirmed orders
    if order.paid? || order.confirmed?
      invoice = order.create_invoice!(
        issued_date: order.created_at.to_date,
        due_date: order.due_date || 30.days.from_now
      )
      # Add payment for paid orders
      if order.paid?
        order.payments.create!(
          invoice: invoice,
          amount: order.total,
          payment_method: :bank_transfer,
          status: :completed,
          payment_date: Date.current - rand(1..30).days,
          reference: "TXN-#{SecureRandom.hex(4).upcase}"
        )
      end
    end
  end
end

# Also add some customers and orders for other sellers
sellers[1..].each do |s|
  2.times do |i|
    c = s.customers.create!(
      name: "Customer #{i + 1} of #{s.name}",
      email: "customer#{i + 1}@#{s.email.split('@').last}",
      active: true
    )
    p = s.products.create!(name: "Service #{i + 1}", price: rand(50..500), unit: "each", active: true)
    o = s.orders.create!(customer: c, status: :pending, due_date: 30.days.from_now)
    o.order_items.create!(description: p.name, quantity: 1, unit_price: p.price, product: p)
  end
end

puts "Seeding complete!"
puts "Admin login: admin@sellerhub.com / password123"
puts "Seller login: alice@techsales.com / password123"
