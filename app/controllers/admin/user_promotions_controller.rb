class Admin::UserPromotionsController < Admin::BaseController
  resource_controller
  helper 'admin/promotions'

  before_filter :load_data

  def collection
    @search = UserPromotion.search(params[:search])

    @promotions = @collection = @search.paginate(
      :per_page => Spree::Config[:per_page],
      :page     => params[:page]
    )
  end

  def load_data
    @available_zones = Zone.find :all, :order => :name
    @calculators = UserPromotion.calculators
  end

  private
  def object
    @promotion ||= super
  end

  before_filter :promotions_submenu
  def promotions_submenu
    render_to_string :partial => 'admin/shared/promotions_sub_menu'
  end
end