# *Promotion" is a class for managing promotions, on sets of products.
#
# h3. Basic usage
#
# Promotion is automatically applied to order by *PromotionOrderObserver* on each order save.
# and automatically removed if they are no longer applicable to order (checked by #eligible?) or
# amount of promotion credit drops to 0.
# All promotion related calculations should be carried out in special calculator, having different calculators,
# allows for different kinds of promotions.
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
# h3. Calculators
#
# Calculators for a promotions have promotion_credit passed to it as argument, which allow for access to both promotion
# (as adjustment_source) and order.

class ProductPromotion < ActiveRecord::Base
  PROMOTED_TYPES = ["Product", "ProductGroup", "Taxon"]

  has_calculator :default => Calculator::FreeShipping
  has_many :promotion_credits, :as => :adjustment_source, :dependent => :nullify
  belongs_to :zone
  belongs_to :promoted, :polymorphic => true

  named_scope :active, {:conditions => [
      "(
         promotions.start_at IS NULL OR promotions.start_at <= ?
       ) AND (
         promotions.end_at IS NULL OR promotions.end_at >= ?
       )",
       Time.now.utc, Time.now.utc
  ]}

  validates_length_of :name, :minimum => 2
  validates_uniqueness_of :name

  # Checks if order is eligible for promotion.
  # if order has at least one item eligible for promotion method returns % of the order
  # that is eligible for promotion(as floating point number between 0 and 1).
  # if order is not eligible returns false
  def eligible?(order)
    eligible = true
    eligible &&= Time.now >= start_at if start_at
    eligible &&= Time.now <= end_at if end_at

    # shipping address is in promotional zones?
    eligible &&= order.shipment && order.ship_address && self.zone.include?(order.ship_address)

    # what percentage of products qualify for promotion?
    if eligible
      qpc = order.line_items(:join => :product).map(&:product) & promoted_products
      eligible = qpc.length > 0 ? (1.0 * qpc.length / order.line_items.length) : false
    end

    return(eligible)
  end

  # Checks if promotion can be combined with other promotions already in order.
  # returns true if any of the following is true:
  #  * promotion is combinable,
  #  * there are no other promotions,
  #  * all other promotions are combinable
  def can_combine?(order)
    self.combine ||
        order.promotion_credits.empty? ||
        order.promotion_credits(:join => :adjustment_source).all?{|pc| pc.adjustment_source.combine}
  end

  # Checks f promotion can be added to the order.
  # returns true if
  #  * order is eligible for promotion
  #  * promotion can be combined with other promotions on order
  #  * this promotion is alredy not used
  def can_be_added?(order)
    eligible?(order) &&
    can_combine?(order) &&
        PromotionCredit.count(:conditions => {
            :adjustment_source_id => self.id,
            :adjustment_source_type => self.class.name,
            :order_id => order.id
        }) == 0
  end

  # Helper method, crates promotion_credit for order.
  #
  # *WARNING*: this method does not check if credit can be created,
  # use #can_be_added? to check it first
  def create_credit(order)
    credit = order.promotion_credits.create({
        :adjustment_source => self,
        :description => I18n.t(name)
    })
    credit
  end

  # Returns array of promoted products
  def promoted_products
    promoted.is_a?(Product) ? [promoted] : promoted.products
  end

  # Helper methods to allow choosing Product / Product Group or Taxon by name.
  before_validation :find_promoted_by_name

  attr_writer :promoted_name
  def promoted_name
    @promoted_name || (promoted && promoted.name)
  end

  def find_promoted_by_name
    if @promoted_name && PROMOTED_TYPES.include?(self.promoted_type)
      self.promoted = self.promoted_type.constantize.find_by_name(@promoted_name)
      self.promoted_id = promoted && promoted.id
    end
  end

  def validate
    errors.add(:promoted_name, "Could not find record with name #{@promoted_name}") unless self.promoted_id
  end
end