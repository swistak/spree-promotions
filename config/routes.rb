map.namespace :admin do |admin|
   admin.resources :product_promotions
   admin.resources :user_promotions
   admin.resources :promotions, :only => [:index]
 end
