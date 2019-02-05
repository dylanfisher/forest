class ImageInput < SimpleForm::Inputs::StringInput

  def input(wrapper_options = nil)
    obj = input_html_options.fetch :object, object
    input_html_options.merge! id: object_name.parameterize
    image_object = obj.send(reflection_or_attribute_name)
    img_src = input_html_options.fetch :img_src, image_object.try(:attachment).try(:url, :medium)
    attribute_name_to_use = reflection.present? ? "#{reflection.name}_id" : attribute_name
    media_item_type = image_object.try(:display_content_type).presence || 'media item'
    button_title = input_html_options.fetch :button_title, "Choose #{media_item_type}"
    compact = options.fetch(:compact, false)

    # TODO: clean this craziness up
    if img_src.nil? && obj.respond_to?(self.input_type)
      img_src = obj.send(self.input_type).try(:attachment).try(:url, :medium)
    end
    path_only    = input_html_options.fetch :path_only, false
    field_name   = input_html_options.fetch :field_name, "#{input_html_options[:id]}"

    modal_data_attributes = {
      toggle: 'modal',
      target: '.media-item-chooser',
      media_item_input: "##{field_name}",
      media_item_modal_path: template.admin_media_items_path
    }

    # TODO: DF 08/04/17 - clarify what this is intened to do... and refactor ImageInput
    path_class = (path_only ? 'media-item-chooser-to-path' : '')

    image_tag_classes = []
    image_tag_classes << path_class
    image_tag_classes << (img_src.blank? ? 'hidden' : '')
    image_tag_classes = image_tag_classes.join(' ')

    content = ActiveSupport::SafeBuffer.new
    buttons = ActiveSupport::SafeBuffer.new

    if image_object.try(:file?) && !image_object.try(:video?)
      content << template.content_tag(:div,
                    nil,
                    class: "media-item-chooser__image media-item-chooser__image--file img-rounded cursor-pointer glyphicon glyphicon-file #{image_tag_classes}",
                    id: "#{field_name}_preview",
                    data: {
                      **modal_data_attributes
                    })
      content << template.text_field_tag('File URL', image_object.attachment.try(:url), readonly: true, class: 'form-control string')
      content << template.tag(:br)
    else
      content << template.image_tag((img_src || ''),
                    class: "media-item-chooser__image img-rounded cursor-pointer #{image_tag_classes}",
                    id: "#{field_name}_preview",
                    data: {
                      **modal_data_attributes
                    })
    end

    buttons << template.content_tag(:button, button_title,
                  type: 'button',
                  class: "media-item-chooser__button btn btn-default #{path_class}",
                  data: {
                    **modal_data_attributes
                  })

    buttons << template.content_tag(:button, "Remove #{media_item_type}",
                  type: 'button',
                  class: "media-item-chooser__remove-image btn btn-default #{'hidden' unless image_object.present?}")

    if image_object.try(:id).present?
      buttons << template.link_to("Edit #{media_item_type}",
                    template.edit_admin_media_item_path(id: image_object.id),
                    class: "media-item-chooser__edit-image btn btn-default",
                    target: '_blank')
    end

    content << template.content_tag(:div, buttons, class: 'image__btn-group btn-group', role: 'group')

    content << @builder.hidden_field(attribute_name_to_use, input_html_options) unless path_only

    template.content_tag(:div, content, class: "image-input__body image-input__body--compact-#{compact.present?}")
  end

end
