module AdminHelper
  def show_admin_navigation?
    # TODO: current_user policy check and potentially some settings check
    @admin_resources && current_user && policy(:dashboard).index?
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

  def admin_page_level_indicator(level)
    (level + 1).times.collect{}.join('&mdash; ').html_safe
  end

  def remote_association(f, association, options = {})
    klass = options.fetch(:class).constantize
    label_name = klass.model_name.plural.titleize
    label_new_link = link_to 'add new', Rails.application.routes.url_helpers.try("new_#{klass.model_name.singular_route_key}_path"), target: '_blank'
    label_all_link = link_to 'view all', Rails.application.routes.url_helpers.try("#{klass.model_name.route_key}_path"), target: '_blank'
    label = label_name + ' ' + [label_new_link, label_all_link].join(', ')
    f.association association,
      collection: f.object.try(association),
      label: label.html_safe,
      include_blank: options.fetch(:include_blank, true),
      input_html: {
        data: {
          remote_path: Rails.application.routes.url_helpers.try("#{klass.model_name.route_key}_path"),
          remote_scope: options.fetch(:scope),
        }
      }
  end

  def admin_navbar_class
    return unless (@page && @page.statusable?)

    if @page.scheduled?
      'bg-info'
    elsif !@page.published?
      'bg-warning'
    end
  end

  def admin_navbar_active_class(nav_item_path)
    'active' if nav_item_path == request.path
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

  def record_name(record)
    record.try(:display_name) || record.try(:title) || record.try(:name)
  end

  def admin_header_tag(record, &block)
    record = record.first if record.respond_to?(:join)
    content_tag :div, capture(&block), class: "admin-header", data: {
      record_type: record&.class&.model_name&.singular,
      record_id: record.try(:id)
    }
  end

  def jquery_include_tag
    if Rails.env.production?
      jquery_url = 'https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js'
    else
      jquery_url = 'forest/lib/jquery-3.2.1.min'
    end
    javascript_include_tag jquery_url, data: { turbolinks_eval: false }
  end
end
