class BlockSelectorInput < SimpleForm::Inputs::CollectionSelectInput
  def input(wrapper_options)
    input_options[:hint] ||= 'Select a block from blocks on this page. You\'ll need to save the page after adding new blocks for them to appear in this list.'

    if object.try(:anchor).present?
      input_html_options[:data] ||= {}
      input_html_options[:data]['selected'] = object.anchor
    end

    super
  end

  def collection
    []
  end
end
