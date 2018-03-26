class CollageInput < SimpleForm::Inputs::CollectionSelectInput

  def label(wrapper_options)
    false
  end

  def input(wrapper_options = nil)
    content = ActiveSupport::SafeBuffer.new
    obj = input_html_options.fetch :object, object
    input_html_options.merge! id: object_name.parameterize

    associated_records = obj.send(reflection_or_attribute_name)

    if object.new_record?
      field_name = input_html_options.fetch(:field_name, "#{input_html_options[:id]}") << SecureRandom.hex
    else
      field_name = input_html_options.fetch :field_name, "#{input_html_options[:id]}"
    end

    cocoon_content = ActiveSupport::SafeBuffer.new

    @builder.simple_fields_for(reflection_or_attribute_name) do |f|
      cocoon_content << template.render('admin/form_inputs/collage/media_item_fields', f: f)
    end

    if associated_records.blank?
      cocoon_content << template.content_tag(:div, 'Click the "Add collage item" button below to add images to this collage.', class: 'collage-input__empty-canvas-message')
    end

    canvas_styles = []

    if object.try(:collage_height_ratio).present?
      canvas_styles << "height: 0"
      canvas_styles << "padding-bottom: #{object.collage_height_ratio}%"
    end

    cocoon_content = template.content_tag(:div, cocoon_content, class: "collage-input__canvas", id: "#{field_name}_preview", style: canvas_styles.join('; '))
    cocoon_content = template.content_tag(:div, cocoon_content, class: "row")

    content << template.content_tag(:div, cocoon_content, class: "collage-input__canvas-wrapper well")

    cocoon_link = template.link_to_add_association('Add collage item',
                                                   @builder,
                                                   reflection_or_attribute_name,
                                                   class: 'collage-input__link-to-add-association btn btn-default',
                                                   partial: 'admin/form_inputs/collage/media_item_fields',
                                                   data: {
                                                    association_insertion_node: "##{field_name}_preview",
                                                    association_insertion_method: 'append' })

    content << template.content_tag(:div, cocoon_link, class: 'collage-input__cocoon-links links')

    content << @builder.hidden_field(:collage_height_ratio, class: 'collage-input__input--height-ratio')

    content
  end

end
