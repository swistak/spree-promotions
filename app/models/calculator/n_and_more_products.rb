class Calculator::NAndMoreProducts < Calculator
  preference :n_items, :integer
  preference :amount,  :decimal
  preference :percent, :decimal

  def compute(promotion_credit)
    order = promotion_credit.order
    promotion = promotion_credit.adjustment_source

    promoted_products = Set.new(promotion.promoted_products)
    li_with_promotion = order.line_items(:join => :product).select{|line_item|
      promoted_products.include?(line_item.product) &&
        line_item.quantity.to_i >= self.preferred_n_items.to_i
    }
    credit = li_with_promotion.map{|li| li.total}.sum * self.preferred_percent / 100.0
    credit += self.preferred_amount
    return(credit)
  end
end