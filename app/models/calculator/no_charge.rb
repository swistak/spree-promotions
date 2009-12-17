class Calculator::NoCharge < Calculator
  preference :charge_type, :type_of_charge

  # Computes the credit adjustment for orders with no charge promotions
  #
  # It multiplies all charges of given type by percentage of all items having this promotion in order,
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
    if eligibility = promotion.eligible?(order)
      eligibility = 1 unless eligibility.is_a?(::Numeric)
      charges = order.charges.all(:conditions => {:type => self.preferred_charge_type})
      -1.0 * charges.map(&:amount).sum * eligibility
    end
  end
end