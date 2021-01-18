module NavigationHelper
  def subnav
    # TODO: cache subnav
    if parent.present?
      parent_page = Page.find_by_path(parent)
      children = parent_page.immediate_children
      render 'shared/subnav', items: children if children.any?
    end
  end

  private

  def parent
    request.path.split('/').reject(&:blank?)[-2]
  end
end
