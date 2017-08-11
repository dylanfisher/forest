class GalleryInput < SimpleForm::Inputs::CollectionSelectInput

  def input(wrapper_options = nil)
    obj = input_html_options.fetch :object, object
    input_html_options.merge! id: object_name.parameterize

    button_title = input_html_options.fetch :button_title, 'Choose Image'
    # img_src      = input_html_options.fetch :img_src, obj.send(reflection_or_attribute_name).try(:attachment).try(:url, :large)

    # TODO: clean this craziness up
    # if img_src.nil? && obj.respond_to?(self.input_type)
    #   img_src = obj.send(self.input_type).try(:attachment).try(:url, :large)
    # end

    # path_only    = input_html_options.fetch :path_only, false
    field_name   = input_html_options.fetch :field_name, "#{input_html_options[:id]}"

    modal_data_attributes = {
      toggle: 'modal',
      target: '.media-item-chooser',
      multiple: true,
      media_item_input: "##{field_name}",
      media_item_modal_path: template.media_items_path
    }

    content = ActiveSupport::SafeBuffer.new

    content << tag(:br)
    content << content_tag(:p, 'test')

    content << template.content_tag(:div, template.content_tag(:div, '', class: "media-gallery-preview row small-gutters", id: "#{field_name}_preview", data: {**modal_data_attributes }), class: 'well')

    content << template.content_tag(:button, button_title,
                  type: 'button',
                  class: "media-item-chooser__button btn btn-xs btn-primary",
                  data: {
                    **modal_data_attributes
                  })

    content << template.content_tag(:button, 'Remove image',
                  type: 'button',
                  class: "media-item-chooser__remove-image btn btn-xs btn-warning #{'hidden' unless obj.send(reflection_or_attribute_name).present?}")

    # TODO: not working yet
    content << @builder.collection_select(
              attribute_name, collection, :id, :title,
              input_options
            )

    content
  end

end
