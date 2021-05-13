class RepeaterInput < SimpleForm::Inputs::TextInput
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    # By default a repeater input is a key/value store. Specify values_only if you don't need keys.
    options.reverse_merge!(values_only: false)
    # Override the key/value placeholder
    options.reverse_merge!(key_placeholder: 'Key')
    options.reverse_merge!(value_placeholder: 'Value')
    # Change the value field tag
    options.reverse_merge!(value_field_tag: 'text_area_tag')

    content = ActiveSupport::SafeBuffer.new
    content << '<div class="repeater__group-wrapper">'.html_safe
    content << repeater_group_fields(options)
    content << '</div>'.html_safe
    content << content_tag(:div, "Add #{attribute_name.to_s.humanize.singularize.downcase}", class: 'repeater__add-item-button btn btn-outline-secondary')
    content << content_tag(:div, nil, class: 'repeater__template', data: { template: repeater_group_fields(options.merge(as_template: true)) })
    content
  end

  private

  def repeater_group_fields(options = {})
    repeater_group_fields = ActiveSupport::SafeBuffer.new
    repeatable_records = object.send(attribute_name)
    if options[:as_template]
      repeater_group_fields << '<div class="repeater__group card bg-light mb-2">'.html_safe
      repeater_group_fields << '<div class="card-header sortable-field-set__handle d-flex p-2">'.html_safe
      repeater_group_fields << "<div class='text-muted'><small>Item</small></div>".html_safe
      repeater_group_fields << repeater_controls
      repeater_group_fields << '</div>'.html_safe
      repeater_group_fields << '<div class="repeater__group__body card-body p-2">'.html_safe
      repeater_group_fields << key_input unless options[:values_only]
      repeater_group_fields << value_input
      repeater_group_fields << '</div>'.html_safe
      repeater_group_fields << '</div>'.html_safe
    elsif repeatable_records.try(:present?)
      repeatable_records&.each_with_index do |row, index|
        repeater_group_fields << '<div class="repeater__group card bg-light mb-2">'.html_safe
        repeater_group_fields << '<div class="card-header sortable-field-set__handle d-flex p-2">'.html_safe
        repeater_group_fields << "<div class='text-muted'><small>Item #{index + 1}</small></div>".html_safe
        repeater_group_fields << repeater_controls
        repeater_group_fields << '</div>'.html_safe
        repeater_group_fields << '<div class="repeater__group__body card-body p-2">'.html_safe
        repeater_group_fields << key_input(row[:key]) unless options[:values_only]
        repeater_group_fields << value_input(row[:value])
        repeater_group_fields << '</div>'.html_safe
        repeater_group_fields << '</div>'.html_safe
      end
    end

    repeater_group_fields << hidden_key_input unless options[:values_only]
    repeater_group_fields << hidden_value_input

    repeater_group_fields
  end

  def key_input(key = nil)
    content_tag(:div, template.text_field_tag("#{object.model_name.singular}[#{attribute_name}][][key]", key, class: 'form-control', required: true, placeholder: options[:key_placeholder]), class: 'form-group')
  end

  def value_input(value = nil)
    content_tag(:div, template.send(options[:value_field_tag], "#{object.model_name.singular}[#{attribute_name}][][value]", value, class: 'form-control', required: true, placeholder: options[:value_placeholder]), class: 'form-group mb-0')
  end

  def hidden_key_input
    template.text_field_tag("#{object.model_name.singular}[#{attribute_name}][][key]", nil, hidden: true, disabled: true, class: 'repeater__disabled-input')
  end

  def hidden_value_input
    template.text_area_tag("#{object.model_name.singular}[#{attribute_name}][][value]", nil, hidden: true, disabled: true, class: 'repeater__disabled-input')
  end

  def repeater_controls
    controls = ActiveSupport::SafeBuffer.new
    controls << '<div class="repeater__controls ml-auto">'.html_safe
    controls << content_tag(:div, template.bootstrap_icon('plus'), class: 'repeater__controls__add-row-button repeater__controls__button btn btn-outline-secondary btn-xs', title: 'Insert item above')
    controls << content_tag(:div, template.bootstrap_icon('dash'), class: 'repeater__controls__remove-row-button repeater__controls__button btn btn-outline-secondary btn-xs ml-1', title: 'Remove item')
    controls << '</div>'.html_safe
  end
end
