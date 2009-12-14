$: << "../" 
require 'test_helper'

class UserPromotionTest < ActiveSupport::TestCase
  context "User Promotion" do
    setup do
      Promotion.delete_all

      @user = Factory(:user)
      # It's important to create order BEFORE promotions, since when order gets saved
      # It'll automatically apply all available promotions
      @order = Factory(:order, :user => @user)
      @zone = Zone.global
      @shipment = @order.shipment
      @shipping_method = Factory(:shipping_method)
      @order.shipment.shipping_method = @shipping_method
      @order.shipment.address = Factory(:address)

      @promotion = Factory(:user_promotion, :combine => true)
      @promotion.users << @user
    end

    context "user logged in" do
      setup do
        activate_authlogic
        UserSession.create(@user)
        @order.save
      end

      should "create promotion credit for user" do
        assert_equal(1, PromotionCredit.count(:conditions => {
              :adjustment_source_id => @promotion_taxon.id,
              :adjustment_source_type => @promotion_taxon.class.name,
              :order_id => @order.id
            }))
      end
    end
  end
end
