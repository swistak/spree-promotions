class Calculator::NthFree < Calculator
  preference :n_items, :integer

  def compute(promotion_credit)
    order = promotion_credit.order
    promotion = promotion_credit.adjustment_source

    credit = order.line_items(:join => :product).inject(0){|sum, line_item|
      if promotion.promoted_products.include?(line_item.product)
        
        free_items = line_item.quantity.to_i / self.preferred_n_items.to_i
        sum + free_items * line_item.price
      else
        sum
      end
    }

    return(credit)
  end
end