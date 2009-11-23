class GroupPromotion < ProductPromotion
  def eligible?(order)
    eligible = true
    eligible &&= Time.now >= start_at if start_at
    eligible &&= Time.now <= end_at if end_at

    # shipping address is in promotional zones?
    eligible &&= order.shipment && order.ship_address && self.zone.include?(order.ship_address)

    # what percentage of products qualify for promotion?
    if eligible
      qpc = order.line_items(:join => :product).map(&:product) & promoted_products
      eligible &&= (qpc.length == promoted_products.length)
    end

    return(eligible)
  end
end