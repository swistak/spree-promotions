class Calculator::SimpleDiscount < Calculator
  preference :amount,  :decimal
  preference :percent, :decimal

  def compute(promotion_credit)
    order = promotion_credit.order
    
    credit = order.item_total * self.preferred_percent / BigDecimal("100")
    credit += self.preferred_amount
    return(credit)
  end
end