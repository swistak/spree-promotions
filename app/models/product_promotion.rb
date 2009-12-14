# ProductPromtion is type of promotion that applies to products.
#
# Requirements for applying promotion:
# * Shipping address has to belong to a zone associated with promotion
# * promotion must be active (see .active scope)
# * order must have at least one product that is promoted.
#
# h3. Promoted types
#
# Promotion can handle any type of object that groups products, promoted model have to provide following methods:
# #name, #products, #human_name (for translation) and #all - that returns list of all objects that can be selected
# When adding promoted type you should also update helper that privdes #link_to_promoted method.
#
class ProductPromotion < Promotion
  PROMOTED_TYPES = ["Product", "ProductGroup", "Taxon"]
  PROMOTION_TYPES = [
    "GroupPromotion",
    "ProductPromotion",
    "FirstPurchasePromotion",
  ]
  include PromotedProducts

  # Checks if order is eligible for promotion.
  # if order has at least one item eligible for promotion method returns % of the order
  # that is eligible for promotion(as floating point number between 0 and 1).
  # if order is not eligible returns false
  def eligible?(order)
    eligible = true
    eligible &&= Time.now >= start_at if start_at
    eligible &&= Time.now <= end_at if end_at
    eligible &&= in_zone?(order)
    
    # what percentage of products qualify for promotion?
    if eligible
      qpc = order.line_items(:join => :product).map(&:product) & promoted_products
      eligible = qpc.length > 0 ? (1.0 * qpc.length / order.line_items.length) : false
    end

    return(eligible)
  end

  def default_calculator
    self.calculator ||= Calculator::FreeShipping.new
  end
end