class CollageInput < SimpleForm::Inputs::CollectionSelectInput

  def label(wrapper_options)
    false
  end

  def input(wrapper_options = nil)
    content = ActiveSupport::SafeBuffer.new
    obj = input_html_options.fetch :object, object
    input_html_options.merge! id: object_name.parameterize

    associated_records = obj.send(reflection_or_attribute_name)
    join_model_reflection = reflection.options[:through]

    raise 'Join model reflection can\'t be determined.' if join_model_reflection.blank?

    field_name = input_html_options.fetch :field_name, "#{input_html_options[:id]}"

    if join_model_reflection.blank?
      images_or_placeholder = template.content_tag(:div, 'Click here to add images to this gallery.', class: 'text-center')
    else
      # images_or_placeholder = associated_records
    end

    preview_html = template.content_tag(:div, images_or_placeholder, class: "collage-input__canvas", id: "#{field_name}_preview")

    content << template.content_tag(:div,
                                    preview_html,
                                    class: "collage-input__canvas-wrapper well")

    cocoon_content = ActiveSupport::SafeBuffer.new
    @builder.simple_fields_for(join_model_reflection) do |f|
      collage_item = template.render('admin/form_inputs/collage/media_item_fields', f: f)
      cocoon_content << template.content_tag(:div, collage_item, class: 'collage-input__item')
    end
    cocoon_link = template.link_to_add_association('Add cocoon item', @builder, join_model_reflection, partial: 'admin/form_inputs/collage/media_item_fields')
    cocoon_content << template.content_tag(:div, cocoon_link, class: 'links')
    content << template.content_tag(:div, cocoon_content, id: join_model_reflection)

    content << @builder.hidden_field(:collage_height_ratio)

    content
  end

end
