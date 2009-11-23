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
  end

  def auto_complete_for_promotion_promoted_name
    find_options = {
      :conditions => [ "LOWER(name) LIKE ?", '%' + params['promotion']['promoted_name'].downcase + '%' ],
      :order => "name ASC",
      :limit => 10
    }

    promoted_class = params['promoted_class']
    promoted_class = 'Product' unless ProductPromotion::PROMOTED_TYPES.include?(promoted_class)
    @items = promoted_class.constantize.find(:all, find_options)

    render :inline => "<%= auto_complete_result @items, 'name' %>"
  end

  private
  def build_object
    promotion_type = (params[:type] || "ProductPromotion").camelize
    promotion_type = "ProductPromotion" unless Promotion::PROMOTIONS.include?(promotion_type)
    @object ||= promotion_type.constantize.new(object_params)
  end


  before_filter :promotions_submenu
  def promotions_submenu
    render_to_string :partial => 'admin/shared/promotions_sub_menu'
  end
end