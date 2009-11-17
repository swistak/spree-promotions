class PromotionOrderObserver < ActiveRecord::Observer
  observe :order

  def before_save(order)
    Promotion.active.each do |promotion|
      promotion.create_credit(order) if promotion.can_be_added?(order)
    end
  end
end