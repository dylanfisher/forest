# A saner alternative to SimpleForm's :grouped_select input type
# https://makandracards.com/makandra/25205-a-saner-alternative-to-simpleform-s-grouped_select-input-type
class GroupedCollectionSelectInput < SimpleForm::Inputs::GroupedCollectionSelectInput

  def input(wrapper_options = nil)
    group_by = options.delete(:group_by)

    if group_by
      grouped_collection = options[:collection].group_by(&group_by)

      options[:collection] = grouped_collection
      options[:group_method] = :last
      options[:group_label_method] = :first
    end

    super
  end

end
