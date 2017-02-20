module AdminHelper
  def show_admin_navigation?
    # TODO: current_user policy check and potentially some settings check
    current_user
  end

  def table_sorter(options = {})
    title = options.fetch :title
    path = options.fetch :path
    scope = options.fetch :scope
    default_order = options.fetch :default_order, :asc
    opposite_order = default_order == :asc ? :desc : :asc
    is_default_order = params[scope]&.to_sym == default_order
    active_class = params[scope].present? ? 'active ' : ''

    link_to title,
      send(path, "#{scope}": (is_default_order ? opposite_order : default_order)),
      class: "#{active_class}#{(is_default_order ? 'order--default' : 'order--reverse')}"
  end

  def admin_navbar_class
    if @version
      'bg-danger'
    elsif @page && !@page.published?
      'bg-warning'
    end
  end

  def admin_area?
    request_parts.first == 'admin'
  end

  def public_area?
    !admin_area?
  end

  def request_parts
    request.path.split('/').reject(&:blank?)
  end
end
