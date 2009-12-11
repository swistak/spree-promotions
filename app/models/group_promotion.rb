class GroupPromotion < ProductPromotion
  def eligible?(order)
    eligible = true
    eligible &&= Time.now >= start_at if start_at
    eligible &&= Time.now <= end_at if end_at
    eligible &&= in_zone?(order)
    
    # what percentage of products qualify for promotion?
    if eligible
      qpc = order.line_items(:join => :product).map(&:product) & promoted_products
      eligible = (qpc.length == promoted_products.length) ? 1 : nil
    end

    return(eligible)
  end
end