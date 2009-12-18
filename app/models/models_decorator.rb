Order.class_eval do
  has_many :promotion_credits, :conditions => {:type => "PromotionCredit"}
end

def Calculator.description
  I18n.t(self.name.split("::").last.underscore, :scope => 'calculators')
end

Product.class_eval do
  def promotions
    ProductPromotion.all.select{|promotion| promotion.include_product_id?(self.id)}
  end
end