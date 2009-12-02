# Load environment if needed
unless defined? SPREE_ROOT
  ENV["RAILS_ENV"] = "test"

  if ENV["SPREE_ENV_FILE"]
    require ENV["SPREE_ENV_FILE"]
  elsif File.dirname(__FILE__) =~ %r{vendor/SPREE/vendor/extensions}
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../../../")}/config/environment"
  else
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../")}/config/environment"
  end
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
    :promoted => active_products,
    :name => "Buy 4 products get one free",
    :calculator => Calculator::NthFree.new(:preferred_n_items => 4),
    :description => "Buy 4 products get one free<br />This is sample description of the promotion",
  })

ProductPromotion.create!({
    :promoted => active_products,
    :name => "Buy 10 products get $10 discount",
    :calculator => Calculator::NAndMoreProducts.new(:preferred_n_items => 4, :preferred_percent => 0, :preferred_amount => 10),
    :description => "Buy 10 products get $10 discount<br />This is sample description of the promotion",
  })