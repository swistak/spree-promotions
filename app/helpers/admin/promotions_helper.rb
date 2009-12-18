module Admin::PromotionsHelper
  def link_to_promoted(promoted)
    path = case promoted
      when Product      then product_path(promoted)
      when Taxon        then edit_admin_taxonomy_path(promoted.taxonomy)
      when ProductGroup then admin_product_group_path(promoted)
    end
    result = path ? link_to(promoted.name, path) : promoted.name
    result += " (#{promoted.class.human_name})"
    result
  end

  def preference_field(form, field, options)
    case options[:type]
    when :integer
      form.text_field(field, {
          :size => 10,
          :class => 'input_integer',
          :readonly => options[:readonly],
          :disabled => options[:disabled]
        }
      )
    when :boolean
      form.check_box(field, {:readonly => options[:readonly],
          :disabled => options[:disabled]})
    when :string
      form.text_field(field, {
          :size => 10,
          :class => 'input_string',
          :readonly => options[:readonly],
          :disabled => options[:disabled]
        }
      )
    when :password
      form.password_field(field, {
          :size => 10,
          :class => 'password_string',
          :readonly => options[:readonly],
          :disabled => options[:disabled]
        }
      )
    when :text
      form.text_area(field,
        {:rows => 15, :cols => 85, :readonly => options[:readonly],
          :disabled => options[:disabled]}
      )
    when :type_of_charge
      form.collection_select(field, [Charge] + Charge.subclasses, :name, :human_name)
    else
      form.text_field(field, {
          :size => 10,
          :class => 'input_string',
          :readonly => options[:readonly],
          :disabled => options[:disabled]
        }
      )
    end
  end
end