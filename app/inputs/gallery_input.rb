class GalleryInput < SimpleForm::Inputs::CollectionSelectInput

  def label(wrapper_options)
    false
  end

  def input(wrapper_options = nil)
    obj = input_html_options.fetch :object, object
    input_html_options.merge! id: object_name.parameterize

    field_name = input_html_options.fetch :field_name, "#{input_html_options[:id]}"

    selected_images = obj.images.collect do |media_item|
      template.content_tag :div, class: 'media-item--grid col-xs-4 col-sm-3 col-md-2' do
        template.content_tag(:div, '', class: 'media-library-image img-rounded',
                              style: "background-image: url(#{media_item.attachment.url(:small)});",
                              data: {
                                media_item_id: media_item.id
                              })
      end
    end

    modal_data_attributes = {
      toggle: 'modal',
      target: '.media-item-chooser',
      multiple: true,
      media_item_input: "##{field_name}",
      media_item_modal_path: template.media_items_path
    }

    modal_data_attributes_for_preview = selected_images.present? ? {} : modal_data_attributes

    if selected_images.present?
      images_or_placeholder = selected_images.join.html_safe
    else
      images_or_placeholder = template.content_tag(:div, 'Click here to add images to this gallery.', class: 'text-center')
    end

    preview_html = template.content_tag(:div, images_or_placeholder, class: "media-gallery-preview row small-gutters", id: "#{field_name}_preview")

    content = ActiveSupport::SafeBuffer.new

    content << template.content_tag(:div,
                                    preview_html,
                                    class: "media-gallery-preview-wrapper #{selected_images.present? ? 'media-gallery-preview-wrapper--has-images' : 'media-gallery-preview-wrapper--no-images'} well",
                                    data: {
                                      **modal_data_attributes_for_preview})

    content << template.content_tag(:button, 'Choose Images',
                  type: 'button',
                  class: "media-item-chooser__button btn btn-default",
                  data: {
                    **modal_data_attributes
                  })

    # TODO: not working yet
    content << @builder.collection_select(attribute_name,
              obj.images, :id, :title,
              {
                selected: obj.send(reflection_or_attribute_name)&.collect(&:id)
              },
              multiple: true,
              id: field_name,
              class: 'gallery__input',
              hidden: true
            )

    content
  end

end
