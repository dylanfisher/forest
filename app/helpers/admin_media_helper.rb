module AdminMediaHelper

  # TODO: Make this more generic so that `path_only` can be specified as an option, otherwise
  # can support returning the image ID for associations.
  def media_item_chooser_to_path(record, options = {})
    button_title = options.fetch :button_title, 'Choose Image'
    field_name = options.fetch :field_name
    column_name = options.fetch :column_name

    modal_data_attributes = {
      toggle: 'modal',
      target: '.media-item-chooser',
      media_item_input: "##{field_name}",
      media_item_modal_path: media_items_path
    }

    capture do
      concat image_tag "#{record.try(column_name)}",
        class: 'img-rounded page__featured-image cursor-pointer media-item-chooser-to-path',
        id: "#{field_name}_preview",
        data: {
          **modal_data_attributes
        }

      concat content_tag :button, button_title,
        type: 'button',
        class: 'btn btn-primary media-item-chooser-to-path',
        data: {
          **modal_data_attributes
        }
    end
  end

end
