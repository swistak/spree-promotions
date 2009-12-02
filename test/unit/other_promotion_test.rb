$: << "../"
require 'test_helper'

class OtherPromotionTest < ActiveSupport::TestCase
  context "OtherPromotion" do
    setup do
      Promotion.delete_all

      @t1 = Factory(:taxon, :name => "t1")
      @t2 = Factory(:taxon, :name => "t2")
      @products = (1..4).map do |x|
        pr = Factory(:product)
        pr.taxons << (x.odd? ? @t1 : @t2)
        pr.save!
        pr
      end
      @t1.reload; @t2.reload;

      # It's important to create order BEFORE promotions, since when order gets saved
      # It'll automatically apply all available promotions
      @order = Factory(:order)
      @zone = Zone.global
      @shipment = @order.shipment
      @shipping_method = Factory(:shipping_method)
      @order.shipment.shipping_method = @shipping_method
      @order.shipment.address = Factory(:address)
    end

    context "GroupPromotion" do
      setup do
        @promotion = Factory(:group_promotion, :promoted => @t1, :combine => true)
        Factory(:line_item, :variant => @products[0].master, :order => @order)
        Factory(:line_item, :variant => @products[1].master, :order => @order)
      end

      should "be eligible for promotion only when all products from the group are in order" do
        assert(!@promotion.eligible?(@order), "Should not be eligible for promotion")
        Factory(:line_item, :variant => @products[2].master, :order => @order)
        assert(@promotion.eligible?(@order))
      end
    end

    context "FirstPurchasePromotion" do
      setup do
        @promotion = Factory(:first_purchase_promotion, :promoted => @t1, :combine => true)
        Factory(:line_item, :variant => @products[0].master, :order => @order)
        Factory(:line_item, :variant => @products[1].master, :order => @order)
        Factory(:line_item, :variant => @products[2].master, :order => @order)
      end

      should "be eligible for promotion only when no other orders were placed" do
        assert(@promotion.eligible?(@order))
      end

      should "not be eligible for promotion only when other completed order was placed" do
        @order.complete! # we finishe the first order

        # and create another one
        @order = Factory(:order)
        @zone = Zone.global
        @shipment = @order.shipment
        @shipping_method = Factory(:shipping_method)
        @order.shipment.shipping_method = @shipping_method
        @order.shipment.address = Factory(:address)
        
        assert(!@promotion.eligible?(@order))
      end
    end
  end
end