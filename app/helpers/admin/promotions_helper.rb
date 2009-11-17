module Admin::PromotionsHelper
  def link_to_promoted(promoted)
    path = case promoted
      when Product      then product_path(promoted)
      when Taxon        then "/s/in_taxon/#{promoted.permalink}"
      when ProductGroup then promoted.to_url
    end
    result = path ? link_to(promoted.name, path) : promoted.name
    result += " (#{promoted.class.human_name})"
    result
  end
end