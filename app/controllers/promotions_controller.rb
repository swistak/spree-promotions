class PromotionsController < Spree::BaseController
  resource_controller :only => [:index, :show]

  helper 'promotions'
end
