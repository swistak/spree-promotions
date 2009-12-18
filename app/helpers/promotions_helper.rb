module PromotionsHelper
  def promotion_for(product)
    promotion = product.promotions.first
    promotion ? (
      '<span class="promotion">'+
        promotion.name+
        '</span>'+
        link_to(t(:promotion_details),
        promotions_path(promotion)
      )) : ''
  end

  def promotions_for(product)
    render :partial => 'promotions/for_product', :locals => {:promotions => product.promotions}
  end

  def link_to_promoted(promoted)
    path = case promoted
    when Product      then product_path(promoted)
    when Taxon        then "/s/in_taxon/#{promoted.permalink}"
    when ProductGroup then '/pg/'+promoted.to_url
    end
    result = path ? link_to(promoted.name, path) : promoted.name
    result
  end
end
