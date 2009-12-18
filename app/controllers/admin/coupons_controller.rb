class Admin::CouponsController < Admin::BaseController
  resource_controller         
  before_filter :load_data

  update.wants.html { redirect_to edit_object_url }
  create.wants.html { redirect_to edit_object_url }

  private       
  before_filter :promotions_submenu
  def promotions_submenu
    render_to_string :partial => 'admin/shared/promotions_sub_menu'
  end

  def build_object
    @object ||= end_of_association_chain.send parent? ? :build : :new, object_params 
    @object.calculator = params[:coupon][:calculator_type].constantize.new if params[:coupon]
  end
  
  def load_data     
    @calculators = Coupon.calculators
    @promoted_types = ProductPromotion::PROMOTED_TYPES.map(&:constantize)
    @promotion_types = ProductPromotion::PROMOTION_TYPES.map(&:constantize)
  end  
end