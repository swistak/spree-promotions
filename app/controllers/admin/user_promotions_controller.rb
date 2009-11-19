class Admin::UserPromotionsController < Admin::BaseController
  resource_controller
  def collection
    @search = UserPromotion.active.search(params[:search])

    @promotions = @collection = @search.paginate(
      :per_page => Spree::Config[:per_page],
      :page     => params[:page]
    )
  end

  private
  before_filter :promotions_submenu
  def promotions_submenu
    render_to_string :partial => 'admin/shared/promotions_sub_menu'
  end
end