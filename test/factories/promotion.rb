Factory.define(:product_promotion, :class => ProductPromotion) do |r|
  r.promoted { Product.all.rand || Factory(:product) }
  r.name {|s| "Free Shipping for #{s.promoted.name}"}
  r.description { Faker::Lorem.paragraphs.join("<br />")}
  r.calculator { Calculator::FreeShipping.new }
  r.zone { Zone.global }
end

Factory.define(:group_promotion, :class => GroupPromotion) do |r|
  r.promoted { Product.all.rand || Factory(:product) }
  r.name {|s| "10% off if you buy all #{s.promoted.name}"}
  r.description { Faker::Lorem.paragraphs.join("<br />")}
  r.calculator { Calculator::FlatRate.new({
        :preferred_amount => 10
  })}
  r.zone { Zone.global }
end

Factory.define(:first_purchase_promotion, :class => FirstPurchasePromotion) do |r|
  r.promoted { Product.all.rand || Factory(:product) }
  r.name {|s| "10% off if you buy all #{s.promoted.name}"}
  r.description { Faker::Lorem.paragraphs.join("<br />")}
  r.calculator { Calculator::FlatRate.new({
        :preferred_amount => 10
  })}
  r.zone { Zone.global }
end

Factory.define(:user_promotion, :class => UserPromotion) do |r|
  r.promoted { Product.all.rand || Factory(:product) }
  r.name {|s| "10$ off for regular customers"}
  r.description { Faker::Lorem.paragraphs.join("<br />")}
  r.calculator { Calculator::FlatRate.new({
        :preferred_amount => 10
  })}
  r.zone { Zone.global }
end