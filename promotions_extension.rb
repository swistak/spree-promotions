# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class PromotionsExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/promotions"

  # Please use promotions/config/routes.rb instead for extension routes.

  # def self.require_gems(config)
  #   config.gem "gemname-goes-here", :version => '1.2.3'
  # end

  def activate
    base = File.dirname(__FILE__)
    Dir.glob(File.join(base, "app/**/*_decorator*.rb")){|c| load(c)}
    FileUtils.cp Dir.glob(File.join(base, "public/stylesheets/*.css")), File.join(RAILS_ROOT, "public/stylesheets/")
    FileUtils.cp Dir.glob(File.join(base, "public/javascripts/*.js")), File.join(RAILS_ROOT, "public/javascripts")

    if ProductPromotion.table_exists?
      Calculator::FreeShipping.register(ProductPromotion)
      UserPromotion.register_calculator(Calculator::FlatPercentItemTotal)
      PromotionOrderObserver.instance
    end

    ::PromotionCredit

    Order.class_eval do
      has_many :promotion_credits, :conditions => {:type => "PromotionCredit"}
    end

    Admin::UsersController.class_eval do
      before_filter :users_submenu
      def users_submenu
        render_to_string :partial => 'admin/shared/user_sub_menu'
      end
    end

    # Add your extension tab to the admin.
    # Requires that you have defined an admin controller:
    # app/controllers/admin/yourextension_controller
    # and that you mapped your admin in config/routes

    #Admin::BaseController.class_eval do
    #  before_filter :add_yourextension_tab
    #
    #  def add_yourextension_tab
    #    # add_extension_admin_tab takes an array containing the same arguments expected
    #    # by the tab helper method:
    #    #   [ :extension_name, { :label => "Your Extension", :route => "/some/non/standard/route" } ]
    #    add_extension_admin_tab [ :yourextension ]
    #  end
    #end

    # make your helper avaliable in all views
    # Spree::BaseController.class_eval do
    #   helper YourHelper
    # end
  end
end
