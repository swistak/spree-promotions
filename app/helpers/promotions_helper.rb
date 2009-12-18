module PromotionsHelper
  def promotion_for(product)
    promotion = product.promotions.first
    promotion ? (
      '<span class="promotion">'+
        promotion.name+
        '</span> '+
        link_to(t(:promotion_details),
        promotion_path(promotion)
      )) : ''
  end

  def promotions_for(product)
    if (promotions = product.promotions) && promotions.first
      content_tag('h3', t(:promotions))+
        content_tag('ul', product.promotions.map{ |promotion|
          content_tag('li', link_to(promotion.name, promotion_path(:id => promotion.id), :class => "promotion"))
        }.join("\n")
      )
    else
      ""
    end
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
