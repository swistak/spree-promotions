module PromotedProducts
  def self.included(klass)
    # Helper methods to allow choosing Product / Product Group or Taxon by name.
    klass.before_validation :find_promoted_by_name
  end

  # Returns array of promoted products
  def promoted_products
    promoted.is_a?(Product) ? [promoted] : promoted.products.all
  end

  
  attr_writer :promoted_name
  def promoted_name
    @promoted_name || (promoted && promoted.name)
  end

  def find_promoted_by_name
    if @promoted_name && ProductPromotion::PROMOTED_TYPES.include?(self.promoted_type)
      self.promoted = self.promoted_type.constantize.find_by_name(@promoted_name)
      self.promoted_id = promoted && promoted.id
    end
  end

  def validate
    errors.add(:promoted_name, "Could not find record with name #{@promoted_name}") unless self.promoted_id
  end
end