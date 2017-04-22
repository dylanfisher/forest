class ImageInput < SimpleForm::Inputs::StringInput

  def input(wrapper_options = nil)
    obj = input_html_options.fetch :object, object
    input_html_options.merge! id: "#{obj.model_name.singular}_#{reflection_or_attribute_name}"

    button_title = input_html_options.fetch :button_title, 'Choose Image'
    img_src      = input_html_options.fetch :img_src, obj.send(reflection_or_attribute_name).try(:attachment).try(:url, :large)
    # TODO: clean this craziness up
    img_src      = (img_src.nil? ? (obj.respond_to?(self.input_type) ? obj.send(self.input_type) : nil) : nil).try(:attachment).try(:url, :large)
    path_only    = input_html_options.fetch :path_only, false
    field_name   = input_html_options.fetch :field_name, "#{input_html_options[:id]}"

    modal_data_attributes = {
      toggle: 'modal',
      target: '.media-item-chooser',
      media_item_input: "##{field_name}",
      media_item_modal_path: template.media_items_path
    }

    path_class = (path_only ? 'media-item-chooser-to-path' : '')

    image_tag_classes = []
    image_tag_classes << path_class
    image_tag_classes << (img_src.blank? ? 'hidden' : '')
    image_tag_classes = image_tag_classes.join(' ')

    content = ActiveSupport::SafeBuffer.new

    content << template.tag(:br)

    content << template.image_tag((img_src || ''),
                  class: "media-item-chooser__image img-rounded cursor-pointer #{image_tag_classes}",
                  id: "#{field_name}_preview",
                  data: {
                    **modal_data_attributes
                  })

    content << template.content_tag(:button, button_title,
                  type: 'button',
                  class: "media-item-chooser__button btn btn-primary #{path_class}",
                  data: {
                    **modal_data_attributes
                  })

    content << template.content_tag(:button, 'Remove image',
                  type: 'button',
                  class: "media-item-chooser__remove-image #{'hidden' unless obj.send(reflection_or_attribute_name).present?} btn btn-link")

    # TODO: This partial renders an additional form, which is not valid HTML.
    # Either the media item modal should not use a form, or the modal needs to be appended
    # after the form.
    content << template.render('media_items/modal')

    content << @builder.hidden_field(attribute_name, input_html_options) unless path_only

    content
  end

end
