module AdminMediaHelper

  def media_item_chooser(record, options = {})
    button_title = options.fetch :button_title, 'Choose Image'
    field_name = options.fetch :field_name
    img_src = options.fetch :img_src
    path_only = options.fetch :path_only, false

    modal_data_attributes = {
      toggle: 'modal',
      target: '.media-item-chooser',
      media_item_input: "##{field_name}",
      media_item_modal_path: media_items_path
    }

    path_class = path_only ? 'media-item-chooser-to-path' : '';

    capture do
      concat image_tag img_src,
        class: "media-item-chooser__image img-rounded cursor-pointer #{path_class}",
        id: "#{field_name}_preview",
        data: {
          **modal_data_attributes
        }

      concat content_tag :button, button_title,
        type: 'button',
        class: "media-item-chooser__button btn btn-primary #{path_class}",
        data: {
          **modal_data_attributes
        }
    end
  end

end
