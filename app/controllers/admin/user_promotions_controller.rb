class Admin::UserPromotionsController < Admin::BaseController
  resource_controller
  before_filter :users_submenu
  before_filter :load_data

  def collection
    @search = UserPromotion.search(params[:search])

    @promotions = @collection = @search.paginate(
      :per_page => Spree::Config[:per_page],
      :page     => params[:page]
    )
  end

  def load_data
    @calculators = UserPromotion.calculators
  end

  private
  def users_submenu
    render_to_string :partial => 'admin/shared/user_sub_menu'
  end
end