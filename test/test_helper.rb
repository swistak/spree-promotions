unless defined? SPREE_ROOT
  ENV["RAILS_ENV"] = "test"
  
  if ENV["SPREE_ENV_FILE"]
    require ENV["SPREE_ENV_FILE"]
  elsif File.dirname(__FILE__) =~ %r{vendor/SPREE/vendor/extensions}
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../../../")}/config/environment"
  else
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../")}/config/environment"
  end
end

require 'test_help'
Dir[File.join(SPREE_ROOT, 'test/factories/*.rb')].each{|f| require(f)}
require "authlogic/test_case"
require 'shoulda'
load File.join(File.dirname(__FILE__), "factories/promotion.rb")
#load File.join(File.dirname(__FILE__), "factories/coupon_factory.rb")

Zone.class_eval do
  def self.global
    find(:first, :conditions => {:name => "GlobalZone"}) || Factory(:global_zone)
  end
end

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end

I18n.locale = "en-US"
Spree::Config.set(:default_country_id => Country.first.id) if Country.first

class ActionController::TestCase
    setup :activate_authlogic
end

ActionController::TestCase.class_eval do
  # special overload methods for "global"/nested params
  [ :get, :post, :put, :delete ].each do |overloaded_method|
    define_method overloaded_method do |*args|
      action,params,extras = *args
      super action, params || {}, *extras unless @params
      super action, @params.merge( params || {} ), *extras if @params
    end
  end
end

def setup
  super
  @params = {}
end