class PromotionsHooks < Spree::ThemeSupport::HookListener
  insert_after(:admin_tabs) do
    tab(:promotions, :product_promotions, :user_promotions, :coupons)
  end
end
