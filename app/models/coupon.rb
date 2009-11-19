# Coupon is special kind of promotion, which is applied only when user provides
# proper coupon code.
#
# Several coupons can be associated with order, but only if all are combinable.
#
class Coupon < ActiveRecord::Base
  has_many  :coupon_credits,    :as => :adjustment_source
  has_calculator
  alias credits coupon_credits

  validates_presence_of :code
  
  def eligible?(order)
    return false if expires_at and Time.now > expires_at
    return false if usage_limit and coupon_credits.count >= usage_limit
    return false if starts_at and Time.now < starts_at
    # TODO - also check items in the order (once we support product groups for coupons)
    true
  end

  # Checks if discount can be combined with other that are already in order.
  # returns true if any of the following is true:
  #  * promotion is combinable,
  #  * there are no other promotions,
  #  * all other promotions are combinable
  def can_combine?(order)
    self.combine && (
      order.credits.empty? ||
      order.credits(:join => :adjustment_source).
      all?{|pc| pc.adjustment_source.combine}
    )
  end

  def create_discount(order)
    if eligible?(order) and amount = calculator.compute(order)
      # Remove all previos coupons, unless we can combine them
      order.coupon_credits.reload.clear unless can_combine?(order)
      
      self.coupon_credits.create({
          :order => order, 
          :amount => amount,
          :description => "#{I18n.t(:coupon)} (#{code})"
        })
    end
  end
end
