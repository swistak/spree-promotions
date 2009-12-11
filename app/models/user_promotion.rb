class UserPromotion < Promotion
  has_and_belongs_to_many :users

  # Checks if order is eligible for promotion.
  def eligible?(order)
    eligible = true
    eligible &&= Time.now >= start_at if start_at
    eligible &&= Time.now <= end_at if end_at
    eligible &&= user = order.user
    eligible &&= self.users.include?(user)
    eligible &&= self.usage_limit > PromotionCredit.count_used(user.id, self.id)
    eligible &&= in_zone?(order)
    return(eligible)
  end

  def default_calculator
    self.calculator ||= Calculator::FlatPercentItemTotal.new
  end
end