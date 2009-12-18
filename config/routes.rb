map.namespace :admin do |admin|
   admin.resources :product_promotions, :collection => {:auto_complete_for_promoted_name => :any}
   admin.resources :user_promotions
   admin.resources :promotions, :only => [:index]
 end

map.resources :promotions