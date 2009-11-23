class PromotionOrderObserver < ActiveRecord::Observer
  observe :order

  def before_save(order)
    if order.changed?
      any_promotion_created = Promotion.active.any? do |promotion|
        if promotion.can_be_added?(order)
          credit = promotion.create_credit(order)
          credit.save! unless order.new_record?
          credit
        end
      end
      if any_promotion_created
        order.adjustment_total = order.charge_total - order.credit_total
        order.total            = order.item_total   + order.adjustment_total
      end
    end
  end
end