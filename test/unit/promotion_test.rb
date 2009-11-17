$: << "../" 
require 'test_helper'
require 'db/seeds.rb'
load File.join(File.dirname(__FILE__), "../factories/promotion.rb")

class PromotionTest < ActiveSupport::TestCase
  #should_validate_uniqueness_of :name

  context "Promotion" do
    setup do
      @t1 = Factory(:taxon, :name => "t1")
      @t2 = Factory(:taxon, :name => "t2")
      @products = (1..4).map do |x|
        pr = Factory(:product)
        pr.taxons << (x.odd? ? @t1 : @t2)
        pr.save!
        pr
      end
      @t1.reload; @t2.reload;

      @promotion_product = Factory(:promotion, :promoted => @products.first, :combine => false)
      @promotion_taxon = Factory(:promotion, :promoted => @t1, :combine => true)
      @promotion_product2 = Factory(:promotion, :promoted => @products[1], :combine => false)

      @order = Factory(:order)
    end

    should "find promoted products" do
      assert_equal @products[0..0], @promotion_product.promoted_products
      assert_equal @t1.products, @promotion_taxon.promoted_products
    end

    should "allow promotion to be combined when there's no previous charges" do
      assert @promotion_product.can_combine?(@order)
      assert(@promotion_taxon.can_combine?(@order))
      assert(@promotion_product2.can_combine?(@order))
    end

    should "allow promotion to be added when all previous promotions are combinable" do
      @promotion_taxon.create_credit(@order)
      assert(@promotion_product.can_combine?(@order))
    end

    should "not allow promotion to be added when any of previous promotions are not combinable" do
      @promotion_product.create_credit(@order)
      assert(!@promotion_product2.can_combine?(@order))
    end

    should "not allow promotion to be added two times even if it's combinable" do
      @promotion_taxon.create_credit(@order)
      assert(!@promotion_taxon.can_be_added?(@order))
    end

    should "not be eligible for promotion when order is empty" do
      assert !@promotion_taxon.eligible?(@order)
    end

    should "find a promoted by type and name" do
      ppr = Promotion.new({
                       :promoted_type => "Product",
                       :promoted_name => @products.first.name
                   })
      ppr.valid? # run the filter
      assert(ppr.promoted, "")
      assert_equal @products.first, ppr.promoted_products.first
    end
  end
end
