class UserPromotion < AbstractPromotion
  # Checks if order is eligible for promotion.
  def eligible?(order)
    eligible = true
    eligible &&= Time.now >= start_at if start_at
    eligible &&= Time.now <= end_at if end_at
    eligible &&= order.user
    eligible &&= self.users.include?(order.user)
    
    return(eligible)
  end

  def default_calculator
    self.calculator ||= Calculator::FlatPercentItemTotal.new
  end
end