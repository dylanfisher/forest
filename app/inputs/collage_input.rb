class CollageInput < SimpleForm::Inputs::CollectionSelectInput

  def label(wrapper_options)
    false
  end

  def input(wrapper_options = nil)
    content = ActiveSupport::SafeBuffer.new
    obj = input_html_options.fetch :object, object
    input_html_options.merge! id: object_name.parameterize

    include_text_box = options.delete(:text_box)
    include_image_width = options.delete(:include_image_width)
    text_box_attr = options.delete(:text_box_attr) || :text

    associated_records = obj.send(reflection_or_attribute_name)

    if object.new_record?
      field_name = input_html_options.fetch(:field_name, "#{input_html_options[:id]}") << SecureRandom.hex
    else
      field_name = input_html_options.fetch :field_name, "#{input_html_options[:id]}"
    end

    cocoon_content = ActiveSupport::SafeBuffer.new

    @builder.simple_fields_for(reflection_or_attribute_name) do |f|
      if f.object.try(text_box_attr).present?
        cocoon_content << template.render('admin/form_inputs/collage/text_box_fields', f: f, obj: obj, text_box_attr: text_box_attr)
      else
        cocoon_content << template.render('admin/form_inputs/collage/media_item_fields', f: f, obj: obj, include_image_width: include_image_width)
      end
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

    content << template.content_tag(:div, cocoon_content, class: "collage-input__canvas-wrapper card bg-light pb-3")

    cocoon_link = template.link_to_add_association('Add collage item',
                                                   @builder,
                                                   reflection_or_attribute_name,
                                                   class: 'collage-input__link-to-add-association btn btn-outline-secondary mt-3',
                                                   partial: 'admin/form_inputs/collage/media_item_fields',
                                                   render_options: {
                                                     locals: {
                                                       obj: obj,
                                                       include_image_width: include_image_width
                                                     }
                                                   },
                                                   data: {
                                                    association_insertion_node: "##{field_name}_preview",
                                                    association_insertion_method: 'append' })

    content << template.content_tag(:div, cocoon_link, class: 'collage-input__cocoon-links links d-inline-block')

    if include_text_box
      cocoon_text_box_link = template.link_to_add_association('Add text box item',
                                                              @builder,
                                                              reflection_or_attribute_name,
                                                              class: 'collage-input__link-to-add-association btn btn-outline-secondary mt-3',
                                                              partial: 'admin/form_inputs/collage/text_box_fields',
                                                              render_options: {
                                                                locals: {
                                                                  obj: obj,
                                                                  text_box_attr: text_box_attr
                                                                }
                                                              },
                                                              data: {
                                                               association_insertion_node: "##{field_name}_preview",
                                                               association_insertion_method: 'append' })

      content << template.content_tag(:div, cocoon_text_box_link, class: 'collage-input__cocoon-links links d-inline-block', style: 'margin-left: 10px;')
    end

    content << @builder.hidden_field(:collage_height_ratio, class: 'collage-input__input--height-ratio')

    content
  end

end
