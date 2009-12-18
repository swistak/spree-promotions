unless Role.new.respond_to?(:users)
  Role.has_and_belongs_to_many :users
end

active_products = ProductGroup.create!({
    :name => "All active products"
  })

ProductPromotion.create!({
    :promoted => active_products,
    :name => "Free Shipping on everything",
    :calculator => Calculator::FreeShipping.new,
    :description => "Free Shipping on everything<br />This is sample description of the promotion",
  })

ProductPromotion.create!({
    :promoted => Product.find_by_name("Ruby on Rails Mug"),
    :name => "Buy 3 Mugs get one free",
    :calculator => Calculator::NthFree.new(:preferred_n_items => 2),
    :description => "Buy 3 jerseys get one free<br />This is sample description of the promotion",
  })

ProductPromotion.create!({
    :promoted => Taxon.find_by_name("Apache"),
    :name => "Buy 4 apache products get $10 discount",
    :calculator => Calculator::NAndMoreProducts.new(:preferred_n_items => 4, :preferred_percent => 0, :preferred_amount => 10),
    :description => "Buy 4 products from apache taxon get $10 discount<br />This is sample description of the promotion",
  })

GroupPromotion.create!({
    :promoted => Taxon.find_by_name("Ruby"),
    :name => "Buy all products from Ruby taxon, get cheapest free",
    :calculator => Calculator::CheapestFree.new,
    :description => "Buy all products from Ruby taxon, get cheapest free"
  })

FirstPurchasePromotion.create!({
    :promoted => Taxon.find_by_name("Bags"),
    :name => "10% off on first purchase of Bags",
    :calculator => Calculator::NAndMoreProducts.new(:preferred_n_items => 1, :preferred_percent => 10, :preferred_amount => 0),
    :description => "First register, then order, you'll get 10% less on all bags in first purchase"
  })

admin_discount = UserPromotion.create!({
    :name => "Admin discount - 90%",
    :description => "All administrators get pernament 90% discount on everything",
    :calculator => Calculator::SimpleDiscount.new(:preferred_percent => 90, :preferred_amount => 0),
  })
admin_discount.users = Role.find_by_name("admin").users
admin_discount.save!

one_time_user_discount = UserPromotion.create!({
    :name => "All users get 1$ discount",
    :description => "All users get 1$ discount on next purchase but only if they buy at least 3 items can be used only once",
    :calculator => Calculator::SimpleDiscount.new(:preferred_percent => 0, :preferred_amount => 1),
    :usage_limit => 1,
  })
one_time_user_discount.users = User.all
one_time_user_discount.save!