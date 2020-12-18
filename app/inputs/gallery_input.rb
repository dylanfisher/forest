class GalleryInput < SimpleForm::Inputs::CollectionSelectInput

  def label(wrapper_options)
    if options[:label]
      super
    else
      false
    end
  end

  def input(wrapper_options = nil)
    obj = input_html_options.fetch :object, object
    input_html_options.merge! id: object_name.parameterize

    associated_records = obj.send(reflection_or_attribute_name)

    field_name = input_html_options.fetch :field_name, "#{input_html_options[:id]}"

    placeholder = options[:placeholder] || content_tag(:div, 'Click here to add images to this gallery.', class: 'card card-body bg-light cursor-pointer mb-3')
    grid_size = options.fetch :size, :default

    selected_images = template.render(partial: 'admin/media_items/media_item_grid_layout', collection: associated_records, as: :media_item, cached: true)

    modal_data_attributes = {
      toggle: 'modal',
      target: '.media-item-chooser',
      multiple: true,
      media_item_input: "##{field_name}",
      media_item_modal_path: template.admin_media_items_path
    }

    modal_data_attributes_for_preview = selected_images.present? ? {} : modal_data_attributes

    if selected_images.blank?
      images_or_placeholder = template.content_tag(:div, placeholder, class: 'text-center col')
    else
      images_or_placeholder = selected_images
    end

    preview_html = template.content_tag(:div, images_or_placeholder, class: "media-gallery-preview row small-gutters", id: "#{field_name}_preview")

    content = ActiveSupport::SafeBuffer.new

    content << template.content_tag(:div,
                                    preview_html,
                                    class: "media-gallery-preview-wrapper media-gallery-preview-wrapper--size-#{grid_size} #{selected_images.present? ? 'media-gallery-preview-wrapper--has-images' : 'media-gallery-preview-wrapper--no-images'} card bg-light px-3 pt-3 mb-3",
                                    data: {
                                      **modal_data_attributes_for_preview})

    content << template.content_tag(:button, 'Choose Images',
                  type: 'button',
                  class: "media-item-chooser__button btn btn-outline-secondary",
                  data: {
                    **modal_data_attributes
                  })

    content << @builder.collection_select(attribute_name,
              associated_records, :id, :title, { selected: associated_records&.collect(&:id) },
              multiple: true,
              id: field_name,
              class: 'gallery__input',
              hidden: true
            )

    content
  end

end
