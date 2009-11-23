class Calculator::NAndMoreProducts < Calculator
  preference :n_items, :integer
  preference :amount,  :decimal
  preference :percent, :decimal

  def compute(promotion_credit)
    order = promotion_credit.order
    promotion = promotion_credit.adjustment_source

    credit = order.line_items(:join => :product).inject(0){|sum, line_item|
      if promotion.promoted_products.include?(line_item.product) &&
          line_item.quantity.to_i > self.preferred_n_items.to_i
        
        sum + 
          self.preferred_amount +
          line_item.price * line_item.quantity.to_i * self.preferred_percent / 100.0
      else
        sum
      end
    }

    return(credit)
  end
end