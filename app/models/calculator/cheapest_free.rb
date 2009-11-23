class Calculator::CheapestFree < Calculator
  def compute(promotion_credit)
    order = promotion_credit.order
    promotion = promotion_credit.adjustment_source

    credit = order.line_items(:join => :product).map{|line_item|
      promotion.promoted_products.include?(line_item.product) ? line_item.price : nil
    }.compact.min

    return(credit)
  end
end