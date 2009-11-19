class FirstPurchasePromotion < Promotion
  # Checks if order is eligible for promotion.
  def eligible?(order)
    eligible = true
    eligible &&= Time.now >= start_at if start_at
    eligible &&= Time.now <= end_at if end_at
    eligible &&= user = order.user
    eligible &&= (user.orders.checkout_complete.count == 0)
    
    return(eligible)
  end

  def default_calculator
    self.calculator ||= Calculator::FlatPercentItemTotal.new
  end
end