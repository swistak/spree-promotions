$: << "../"
require 'test_helper'

class ProductPromotionTest < ActiveSupport::TestCase
  context "ProductPromotion" do
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

      @promotion_product = Factory(:product_promotion, :promoted => @products.first, :combine => false)
      @promotion_taxon = Factory(:product_promotion, :promoted => @t1, :combine => true)
      @promotion_product2 = Factory(:product_promotion, :promoted => @products[1], :combine => false)

      Factory(:line_item, :variant => @products.first.master, :order => @order)
      Factory(:line_item, :variant => @products[1].master, :order => @order)
    end

    [:promotion_product, :promotion_taxon, :promotion_product2].each do |promotion_name|
      context promotion_name do
        setup do
          @promotion = instance_variable_get("@#{promotion_name}")
        end

        should "be product promotion" do
          assert(@promotion.is_a?(ProductPromotion), "#{promotion_name} is not a ProductPromotion")
        end

        should "be eligible" do
          assert(@promotion.eligible?(@order), "order is not eligible for #{promotion_name}")
        end

        should "include address in zone" do
          # sanity checks
          assert(@order.shipment, "Order doesn't have a shipment")
          assert(@order.ship_address, "Order doesn't have a shipping address")
          assert(@promotion.zone.include?(@order.ship_address), "#{promotion_name} is not active")
        end
      end
    end

    should "find promoted products" do
      assert_equal @products[0..0], @promotion_product.promoted_products
      assert_equal @t1.products, @promotion_taxon.promoted_products
    end

    should "allow promotion to be added when there's no previous charges" do
      assert @promotion_product.can_be_added?(@order)
      assert(@promotion_taxon.can_be_added?(@order))
      assert(@promotion_product2.can_be_added?(@order))
    end

    context "with credit created" do
      setup do
        assert_equal(ProductPromotion, @promotion_taxon.class)
        @promotion_taxon.create_credit(@order).save!
      end
      should_change("PromotionCredit.count") { PromotionCredit.count }

      should "create proper credit" do
        assert_equal(1, PromotionCredit.count(:conditions => {
              :adjustment_source_id => @promotion_taxon.id,
              :adjustment_source_type => @promotion_taxon.class.name,
              :order_id => @order.id
            }))
      end

      should "not allow promotion to be added when all previous promotions are combinable" do
        assert(!@promotion_product.can_combine?(@order))
      end

      should "not allow promotion to be added when any of previous promotions are not combinable" do
        assert(!@promotion_product2.can_combine?(@order))
      end

      should "not allow promotion to be added two times even if it's combinable" do
        assert(!@promotion_taxon.can_be_added?(@order))
      end
    end

    should "not be eligible for promotion when order is empty" do
      @order = Order.new
      assert !@promotion_taxon.eligible?(@order)
    end

    should "find a promoted by type and name" do
      ppr = ProductPromotion.new({
          :promoted_type => "Product",
        })
      ppr.promoted_name = @products.first.name
      ppr.valid? # run the filter
      assert(ppr.promoted, "")
      assert_equal @products.first, ppr.promoted_products.first
    end
  end
end