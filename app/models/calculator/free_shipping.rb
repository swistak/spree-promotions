class Calculator::FreeShipping < Calculator
  # Computes the credit adjustment for orders with free shipping promotions
  #
  # It multiplies all shipping charges by percentage of all items having this promotion in order,
  # this have advantage over other approaches that it'll work nicely with multiple promotions,
  # on different products in order as long as they don't overlap.
  # Also this reasembles current behaviour of fogdog
  #
  # There can be several other behaviours here.
  # We might want to apply discount to only first shipping method or discount all shipments
  # regardles of amount of items in promotion.
  def compute(promotion_credit)
    order = promotion_credit.order
    promotion = promotion_credit.adjustment_source
    if (eligibility = promotion.eligible?(order))
      eligibility = 1 unless eligibility.is_a?(::Numeric)
      1.0 * order.shipping_charges.map(&:amount).sum * eligibility
    end
  end
end