$: << "../"
require 'test_helper'
load File.join(File.dirname(__FILE__), "../factories/promotion.rb")

class PromotionsCalculatorsTest < ActiveSupport::TestCase
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
      @shipment.save

      @order.line_items << Factory(:line_item, {
          :variant => @products[0].master,
          :order => @order,
          :quantity => 4,
          :price => "10.99"
        })
      @order.line_items << Factory(:line_item, {
          :variant => @products[1].master,
          :order => @order,
          :quantity => 1,
          :price => "1"
        })
    end

    should "Perform sane calculations, and update all totals correctly on save" do
      @promotion_taxon = Factory(:product_promotion, :promoted => @t1, :combine => true)
      assert_in_delta(0.5, @promotion_taxon.eligible?(@order), 0.01, "@order is not eligible for promotion")
      @order.save

      assert_equal(10, @order.ship_total)

      assert_in_delta(5, Calculator::FreeShipping.new.compute(@order.promotion_credits.first), 0.01)
      assert_in_delta(5, @order.credit_total, 0.01)

      assert_equal(
        (@order.tax_total + @order.ship_total - @order.credit_total).to_s,
        @order.adjustment_total.to_s
      )
      assert_equal(
        (@order.item_total - @order.credit_total + @order.tax_total + @order.ship_total).to_s,
        @order.total.to_s
      )
    end

    should "Calculate free shipping promotion properly for 3 items, 2 in promotion" do
      @order.line_items << Factory(:line_item, {
          :variant => @products[2].master,
          :order => @order,
          :quantity => 1,
          :price => "1"
        })
      @promotion_taxon = Factory(:product_promotion, :promoted => @t1, :combine => true)
      assert_in_delta(2.0/3, @promotion_taxon.eligible?(@order), 0.01, "@order is not eligible for promotion")
      @order.save

      assert_equal(10, @order.ship_total)

      assert_in_delta(20.0/3, Calculator::FreeShipping.new.compute(@order.promotion_credits.first), 0.01)
    end

    should "Calculate tax free for 3 items, 2 in promotion" do
      @order.line_items << Factory(:line_item, {
          :variant => @products[2].master,
          :order => @order,
          :quantity => 1,
          :price => "1"
        })
      @promotion_taxon = Factory(:product_promotion,{
        :promoted => @t1,
        :combine => true,
        :calculator => Calculator::NoCharge.new(:preferred_charge_type => "TaxCharge" )
      })

      assert_in_delta(2.0/3, @promotion_taxon.eligible?(@order), 0.01, "@order is not eligible for promotion")
      @order.save

      assert_equal(10, @order.ship_total)

      assert_in_delta(-2.0/3 * @order.tax_total, @order.promotion_credits.first.amount, 0.01)
    end

    should "Calculate n-th free for n=3 and 2 and 10 items" do
      @order.line_items << Factory(:line_item, {
          :variant => @products[2].master,
          :order => @order,
          :quantity => 10,
          :price => "1"
        })
      @promotion_taxon = Factory(:product_promotion,{
        :promoted => @t1,
        :combine => true,
        :calculator => Calculator::NthFree.new(:preferred_n_items => 3)
      })

      assert(@promotion_taxon.eligible?(@order), "@order is not eligible for promotion")
      @order.save

      assert_in_delta(3 * 1 + 10.99, -1 * @order.promotion_credits.first.amount, 0.01)
    end

    should "Calculate credit for cheapest item" do
      @order.line_items << Factory(:line_item, {
          :variant => @products[2].master,
          :order => @order,
          :quantity => 10,
          :price => "1"
        })
      @promotion_taxon = Factory(:product_promotion,{
        :promoted => @t1,
        :combine => true,
        :calculator => Calculator::CheapestFree.new()
      })

      assert(@promotion_taxon.eligible?(@order), "@order is not eligible for promotion")
      @order.save

      assert_in_delta(1, -1 * @order.promotion_credits.first.amount, 0.01)
    end

    should "Calculate credit for discount on n or more products for n=3" do
      @order.line_items << Factory(:line_item, {
          :variant => @products[2].master,
          :order => @order,
          :quantity => 10,
          :price => "1"
        })
      @promotion_taxon = Factory(:product_promotion,{
        :promoted => @t1,
        :combine => true,
        :calculator => Calculator::NAndMoreProducts.new(
          :preferred_amount => 1,
          :preferred_percent => 1,
          :preferred_n_items => 3
        )
      })

      assert(@promotion_taxon.eligible?(@order), "@order is not eligible for promotion")
      @order.save

      promoted_total = 10 * 1 + 4 * BigDecimal("10.99")
      assert_in_delta(promoted_total * 0.01 + 1, -1 * @order.promotion_credits.first.amount.to_f, 0.01)
    end
  end
end
