class Admin::PromotionsController < Admin::BaseController
  resource_controller
  before_filter :products_submenu
  before_filter :load_data
  
  def collection
    @search = Promotion.search(params[:search])

    @collection = @search.paginate(
      :per_page => Spree::Config[:per_page],
      :page     => params[:page]
    )
  end

  def load_data
    @available_zones = Zone.find :all, :order => :name
    @calculators = Promotion.calculators
    @promoted_types = Promotion::PROMOTED_TYPES.map(&:constantize)
    @promoted_names = {}
    @promoted_types.each do |klass|
      @promoted_names[klass.to_s] = klass.all.map(&:name) 
    end
  end

  private
  def products_submenu
    render_to_string :partial => 'admin/shared/product_sub_menu'
  end
end