Factory.define(:product_promotion) do |r|
  r.promoted { Product.all.rand || Factory(:product) }
  r.name {|s| "Free Shipping for #{s.promoted.name}"}
  r.description { Faker::Lorem.paragraphs.join("<br />")}
  r.calculator { Calculator::FreeShipping.new }
  r.zone { Zone.global }
end