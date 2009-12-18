class PromotionOrderObserver < ActiveRecord::Observer
  observe :order

  def before_save(order)
    if order.changed?
      # Don't ever change this to .any? as it'll add only one promotion!
      new_promotions = Promotion.active.map{ |promotion|
        if promotion.can_be_added?(order)
          credit = promotion.create_credit(order)
          credit.save! unless order.new_record?
          credit
        end
      }.compact
      unless new_promotions.empty?
        order.adjustment_total = order.charge_total - order.credit_total
        order.adjustment_total = -order.item_total if order.adjustment_total < -order.item_total
        order.total            = order.item_total   + order.adjustment_total
      end
    end
    new_promotions || true # Always return true or we'll halt the call chain
  end
end