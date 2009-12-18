class Admin::ProductPromotionsController < Admin::BaseController
  resource_controller
  before_filter :load_data
  helper 'admin/promotions'

  def collection
    @search = ProductPromotion.search(params[:search])

    @promotions = @collection = @search.paginate(
      :per_page => Spree::Config[:per_page],
      :page     => params[:page]
    )
  end

  def load_data
    @available_zones = Zone.find :all, :order => :name
    @calculators = ProductPromotion.calculators
    @promoted_types = ProductPromotion::PROMOTED_TYPES.map(&:constantize)
    @promotion_types = ProductPromotion::PROMOTION_TYPES.map(&:constantize)
  end

  def auto_complete_for_promoted_name
    name = (params['promotion'] || params['product_promotion'] || params['coupon'])['promoted_name']
    find_options = {
      :conditions => [ "LOWER(name) LIKE ?", '%' + name.downcase + '%' ],
      :order => "name ASC",
      :limit => 10
    }

    promoted_class = params['promoted_class']
    promoted_class = 'Product' unless ProductPromotion::PROMOTED_TYPES.include?(promoted_class)
    @items = promoted_class.constantize.find(:all, find_options)

    render :inline => "<%= auto_complete_result @items, 'name' %>"
  end

  create.response do |wants|
    wants.html do
      if @promotion.calculator.respond_to?(:preferences) && @promotion.calculator.preferences.length > 0
        flash[:notice] = t(:set_preferences)
        redirect_to(edit_object_url)
      else
        redirect_to(object_url)
      end
    end
  end

  update.response do |wants|
    wants.html do
      redirect_to(edit_object_url)
    end
  end

  private
  def object
    @promotion ||= super
  end

  def build_object
    promotion_type = params[:promotion] ? params[:promotion][:type] : params[:type]
    promotion_type = (promotion_type || "ProductPromotion").camelize
    promotion_type = "ProductPromotion" unless ProductPromotion::PROMOTION_TYPES.include?(promotion_type)
    @promotion = @object ||= promotion_type.constantize.new(params[:promotion])
  end


  before_filter :promotions_submenu
  def promotions_submenu
    render_to_string :partial => 'admin/shared/promotions_sub_menu'
  end
end