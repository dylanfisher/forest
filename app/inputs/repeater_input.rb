class RepeaterInput < SimpleForm::Inputs::TextInput
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    content = ActiveSupport::SafeBuffer.new
    content << '<div class="repeater__group-wrapper">'.html_safe
    content << repeater_group_fields
    content << '</div>'.html_safe
    content << content_tag(:div, "Add #{attribute_name.to_s.humanize.downcase}", class: 'repeater__add-item-button btn btn-default')
    content << content_tag(:div, '', class: 'repeater__template', data: { template: repeater_group_fields(as_template: true) })
    content
  end

  private

    def repeater_group_fields(options = {})
      repeater_group_fields = ActiveSupport::SafeBuffer.new
      if object.send(attribute_name).try(:blank?) || options[:as_template]
        repeater_group_fields << '<div class="repeater__group panel panel-default">'.html_safe
        repeater_group_fields << '<div class="repeater__group__body panel-body">'.html_safe
        repeater_group_fields << key_input
        repeater_group_fields << value_input
        repeater_group_fields << '</div>'.html_safe
        repeater_group_fields << repeater_controls
        repeater_group_fields << '</div>'.html_safe
      else
        object.send(attribute_name).each do |row|
          repeater_group_fields << '<div class="repeater__group panel panel-default">'.html_safe
          repeater_group_fields << '<div class="repeater__group__body panel-body">'.html_safe
          repeater_group_fields << key_input(row[:key])
          repeater_group_fields << value_input(row[:value])
          repeater_group_fields << '</div>'.html_safe
          repeater_group_fields << repeater_controls
          repeater_group_fields << '</div>'.html_safe
        end
      end
      repeater_group_fields
    end

    def key_input(key = nil)
      content_tag(:div, template.text_field_tag("#{object.model_name.singular}[#{attribute_name}][][key]", key, class: 'form-control', required: true), class: 'form-group')
    end

    def value_input(value = nil)
      content_tag(:div, template.text_area_tag("#{object.model_name.singular}[#{attribute_name}][][value]", value, class: 'form-control', required: true), class: 'form-group')
    end

    def repeater_controls
      controls = ActiveSupport::SafeBuffer.new
      controls << '<div class="repeater__controls">'.html_safe
      controls << '<div class="repeater__controls__buttons">'.html_safe
      controls << content_tag(:div, '', class: 'repeater__controls__add-row-button repeater__controls__button btn btn-default btn-xs glyphicon glyphicon-plus')
      controls << content_tag(:div, '', class: 'repeater__controls__remove-row-button repeater__controls__button btn btn-default btn-xs glyphicon glyphicon-minus')
      controls << '</div>'.html_safe
      controls << '</div>'.html_safe
    end
end
