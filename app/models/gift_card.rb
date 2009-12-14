class GiftCard < ActiveRecord::Base
  belongs_to :zone
  belongs_to :promoted,             :polymorphic => true
  has_many   :gift_card_credits,    :as => :adjustment_source
  has_calculator
  alias credits gift_card_credits

  named_scope :active, {:conditions => [
      "(
         gift_cards.start_at IS NULL OR gift_cards.start_at <= ?
       ) AND (
         gift_cards.end_at IS NULL OR gift_cards.end_at >= ?
       )",
      Time.now.utc, Time.now.utc
    ]}
  
  validates_presence_of :code

  def eligible?(order)
    eligible = true
    
    eligible &&= Time.now < start_at if start_at
    eligible &&= Time.now > end_at   if end_at
    eligible &&= amount > 0
    
    # shipping address is in promotional zones?
    if self.zone
      eligible &&= order.shipment && order.ship_address
      eligible &&= self.zone.include?(order.ship_address)
    end

    # is there at least one product that can be bought with this gift_card?
    if eligible && !promoted_products.blank?
      # check for eligibility only when gift_card has promoted products
      qpc = order.line_items(:join => :product).map(&:product) & promoted_products
      eligible = qpc.length > 0
    end

    return(eligible)
  end

  # Checks if discount can be combined with other that are already in order.
  #
  # Gift card discounts are always combinable.
  def can_combine?(order)
    true
  end

  def create_discount(order)
    if eligible?(order) and amount = calculator.compute(order)
      # Remove all previos coupons, unless we can combine them
      order.gift_card_credits.reload.clear unless can_combine?(order)
      
      self.gift_card_credits.create({
          :order => order, 
          :amount => amount,
          :description => "#{I18n.t(:gift_card)} (#{code})"
        })
    end
  end
end
