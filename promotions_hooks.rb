class PromotionsHooks < Spree::ThemeSupport::HookListener
  insert_after(:admin_tabs) do
    '<%= tab(:promotions, :product_promotions, :user_promotions, :coupons) %>'
  end

  # Comment out following lines if you don't want promotion hooks in your layout

  insert_after(:product_price) do
    '<%= promotions_for(@product) %>'
  end

  insert_after(:product_list_price) do
    '<%= product.promotions.map{|pr| pr.name}.join("<br />") %>'
  end
end
