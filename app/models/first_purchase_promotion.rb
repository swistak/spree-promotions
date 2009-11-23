class FirstPurchasePromotion < ProductPromotion
  # Checks if order is eligible for promotion.
  def eligible?(order)
    super && order.user && (order.user.orders.checkout_complete.count == 0)
  end
end