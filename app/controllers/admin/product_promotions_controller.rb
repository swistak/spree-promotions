class Admin::ProductPromotionsController < Admin::BaseController
  resource_controller
  before_filter :load_data

  def collection
    @search = ProductPromotion.active.search(params[:search])

    @promotions = @collection = @search.paginate(
      :per_page => Spree::Config[:per_page],
      :page     => params[:page]
    )
  end

  def load_data
    @available_zones = Zone.find :all, :order => :name
    @calculators = ProductPromotion.calculators
    @promoted_types = ProductPromotion::PROMOTED_TYPES.map(&:constantize)
    @promoted_names = {}
    @promoted_types.each do |klass|
      @promoted_names[klass.to_s] = klass.all.map(&:name)
    end
  end

  private
  before_filter :promotions_submenu
  def promotions_submenu
    render_to_string :partial => 'admin/shared/promotions_sub_menu'
  end
end