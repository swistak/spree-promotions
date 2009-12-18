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
    errors.add(:promoted_name, "Could not find #{self.promoted_type} with name #{@promoted_name}") unless self.promoted_id
  end

  def include_product?(product)
    include_product_id?(product.id)
  end

  def include_product_id?(product_id)
    case promoted
    when Product
      product_id == promoted.id
    when ProductGroup
      promoted.products.scoped(:conditions => {:id => product_id}).count > 0
    when Taxon
      Product.in_taxon(promoted).scoped(:conditions => {:id => product_id}).count > 0
    else
      promoted.products.map(&:id).include?(product_id)
    end
  end
end