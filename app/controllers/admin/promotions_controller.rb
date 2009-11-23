class Admin::PromotionsController < Admin::BaseController
  helper 'admin/promotions'

  def index
    @search = Promotion.active.search(params[:search])

    @promotion_count = @search.count(:group => 'promotions.type')
  end

  private
  before_filter :promotions_submenu
  def promotions_submenu
    render_to_string :partial => 'admin/shared/promotions_sub_menu'
  end
end