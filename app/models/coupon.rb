# Coupon is special kind of promotion, which is applied only when user provides
# proper coupon code.
#
# Several coupons can be associated with order, but only if all are combinable.
#
class Coupon < ActiveRecord::Base
  belongs_to :zone
  belongs_to :promoted, :polymorphic => true
  has_many   :coupon_credits,    :as => :adjustment_source
  has_calculator
  alias credits coupon_credits

  include PromotedProducts

  validates_presence_of :code

  # If zone is defined - checks if order has shipping address and address is in eligible zone.
  # If not assumes promotion is global.
  def in_zone?(order)
    # shipping address is in promotional zones?
    if self.zone
      order.shipment && order.ship_address && self.zone.include?(order.ship_address)
    else
      true
    end
  end

  def eligible?(order)
    eligible = true
    
    eligible &&= Time.now < starts_at  if starts_at
    eligible &&= Time.now > expires_at if expires_at
    eligible &&= coupon_credits.count >= usage_limit if usage_limit
    eligible &&= in_zone?(order)

    # is there at least one product that can be bought with coupon?
    if eligible && !promoted_products.blank?
      # check for eligibility only when coupon has promoted products
      qpc = order.line_items(:join => :product).map(&:product) & promoted_products
      eligible = qpc.length > 0
    end

    return(eligible)
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
