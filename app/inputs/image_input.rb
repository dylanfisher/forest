class ImageInput < SimpleForm::Inputs::StringInput

  def input(wrapper_options = nil)
    obj = input_html_options.fetch :object, object
    input_html_options.merge! id: object_name.parameterize
    image_object = obj.send(reflection_or_attribute_name)
    attribute_name_to_use = reflection.present? ? "#{reflection.name}_id" : attribute_name
    media_item_type = image_object.try(:display_content_type).presence || 'media item'
    button_title = input_html_options.fetch :button_title, template.bootstrap_icon('collection', embedded: true) + " Choose"
    compact = options.fetch(:compact, false) # Make a smaller image input
    media_item_scope = options.fetch(:scope, nil)

    # TODO: clean this craziness up
    default_image_url = image_object.try(:attachment_url, :medium)
    # TODO: better support for vimeo videos - should this be moved into a video_input.rb file?
    default_image_url = image_object.vimeo_video_thumbnail if image_object.try(:vimeo_video?)
    img_src = input_html_options.fetch(:img_src, default_image_url)
    if img_src.nil? && obj.respond_to?(self.input_type)
      img_src = obj.send(self.input_type).try(:attachment_url, :medium)
    end
    path_only    = input_html_options.fetch :path_only, false
    field_name   = input_html_options.fetch :field_name, "#{input_html_options[:id]}"

    modal_data_attributes = {
      toggle: 'modal',
      target: '.media-item-chooser',
      media_item_input: "##{field_name}",
      media_item_modal_path: template.admin_media_items_path,
      media_item_scope: media_item_scope
    }

    path_class = (path_only ? 'media-item-chooser-to-path' : '')

    image_tag_classes = []
    image_tag_classes << path_class
    image_tag_classes << (img_src.blank? ? 'd-none' : '')
    image_tag_classes = image_tag_classes.join(' ')

    content = ActiveSupport::SafeBuffer.new
    buttons = ActiveSupport::SafeBuffer.new

    if image_object.try(:video?) && !image_object.try(:vimeo_video?)
      image_thumbnail = template.video_tag((img_src || image_input_uri_image_placeholder),
                          class: "media-item-chooser__image media-item-chooser__image--video mb-3 rounded cursor-pointer #{image_tag_classes}",
                          id: "#{field_name}_preview",
                          controls: true,
                          preload: 'metadata',
                          data: {
                            **modal_data_attributes
                          })
      content << template.content_tag(:div, template.content_tag(:div, image_thumbnail, class: 'media-item-chooser__image-wrapper__inner'), class: 'media-item-chooser__image-wrapper')
    elsif image_object.try(:audio?)
      audio_content = ActiveSupport::SafeBuffer.new
      audio_content << template.content_tag(:div,
                    nil,
                    class: "media-item-chooser__image media-item-chooser__image--file rounded cursor-pointer glyphicon glyphicon-audio #{image_tag_classes} mr-3",
                    id: "#{field_name}_preview",
                    data: {
                      **modal_data_attributes
                    })
      audio_content << template.audio_tag(image_object.try(:attachment_url), controls: true)
      audio_content = template.content_tag(:div, audio_content, class: 'd-flex align-items-center mr-3')
      content << audio_content
      content << template.tag(:br)
    elsif image_object.try(:file?) && !image_object.try(:vimeo_video?)
      content << template.content_tag(:div,
                    nil,
                    class: "media-item-chooser__image media-item-chooser__image--file rounded cursor-pointer glyphicon glyphicon-file-richtext #{image_tag_classes}",
                    id: "#{field_name}_preview",
                    data: {
                      **modal_data_attributes
                    })
      content << template.label_tag('File URL', nil, class: 'mt-3')
      content << template.text_field_tag('File URL', image_object.try(:attachment_url), readonly: true, class: 'form-control string')
      content << template.tag(:br)
    else
      image_thumbnail = template.image_tag((img_src || image_input_uri_image_placeholder),
                          class: "media-item-chooser__image mb-3 rounded cursor-pointer #{image_tag_classes}",
                          id: "#{field_name}_preview",
                          data: {
                            **modal_data_attributes
                          })
      image_thumbnail << template.content_tag(:span, '', class: "media-item--grid__icon glyphicon glyphicon-#{image_object.glyphicon}") if image_object.try(:file?).present?
      content << template.content_tag(:div, template.content_tag(:div, image_thumbnail, class: 'media-item-chooser__image-wrapper__inner'), class: 'media-item-chooser__image-wrapper')
    end

    buttons << template.content_tag(:button, button_title,
                  type: 'button',
                  class: "media-item-chooser__button btn btn-outline-secondary #{path_class}",
                  data: {
                    **modal_data_attributes
                  })

    buttons << template.content_tag(:button, template.bootstrap_icon('x-lg', embedded: true) + ' Remove',
                  type: 'button',
                  class: "media-item-chooser__remove-image btn btn-outline-secondary #{'d-none' if image_object.blank?}")

    buttons << template.link_to(template.bootstrap_icon('pencil', embedded: true) + ' Edit',
                  (image_object.try(:id).present? ? template.edit_admin_media_item_path(id: image_object.id) : '#'),
                  class: "media-item-chooser__edit-image btn btn-outline-secondary #{'d-none' if image_object.blank?}",
                  target: '_blank')

    content << template.content_tag(:div, buttons.html_safe, class: "image__btn-group #{'image__btn-group--blank-image' if image_object.blank?} btn-group", role: 'group')

    content << @builder.hidden_field(attribute_name_to_use, input_html_options) unless path_only

    template.content_tag(:div, content, class: "image-input__body image-input__body--compact-#{compact.present?}")
  end


  def image_input_uri_image_placeholder
    'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='
  end
end
