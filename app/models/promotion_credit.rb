class PromotionCredit < Credit
  # Counts used promotion credits for given user and promotion ids.
  def self.count_used(user_id, adjustment_source_id)
    count(
      :joins => :order,
      :conditions => [
        "orders.completed_at IS NOT NULL AND orders.user_id = ? AND #{table_name}.adjustment_source_id = ?",
        user_id, adjustment_source_id
      ])
  end

  def applicable?
    adjustment_source && adjustment_source.eligible?(order) && super
  end

  # Tries to calculate the adjustment, returns nil if adjustment could not be calculated.
  def calculate_adjustment
    if adjustment_source && adjustment_source.respond_to?(:calculator)
      calc = adjustment_source.calculator
      result = calc && calc.compute(self)
      if promoted_products = adjustment_source.promoted_products
        ceiling = order.
          line_items(:join => :product).
          select{|li| promoted_products.include?(li.product)}.
          map(&:total).
          sum
      else
        ceiling = order.item_total
      end
      result = ceiling if result.to_i.abs > ceiling.abs
      result && -result.abs
    end
  end
end