class PromotionCredit < Credit
  # Counts used promotion credits for given user and promotion ids.
  def self.count_used(user_id, adjustment_source_id)
    count(
      :joins => :order,
      :conditions => {
        'orders.user_id' => user_id,
        :adjustment_source_id => adjustment_source_id
      })
  end

  def applicable?
    adjustment_source && adjustment_source.eligible?(order) && super
  end

  # Tries to calculate the adjustment, returns nil if adjustment could not be calculated.
  def calculate_adjustment
    if adjustment_source && adjustment_source.respond_to?(:calculator)
      calc = adjustment_source.calculator
      calc.compute(self) if calc
    end
  end

  def before_save
    self.amount = order.item_total if self.amount > order.item_total
  end

  def before_destroy
    
  end
end