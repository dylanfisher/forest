module AdminHelper
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

  def table_thumbnail(image)
    if image&.attachment.present?
      content_tag :div, class: 'table-thumbnail' do
        image_tag image.attachment.url(:thumb)
      end
    end
  end

  def table_color_representation(color)
    content_tag :div, '', class: 'table-color-representation', style: "background-color: #{color};"
  end

  def forest_date(datetime)
    datetime_format = datetime.is_a?(Date) ? '%m-%d-%Y' : '%m-%d-%Y %l:%M %p'
    datetime.strftime(datetime_format).html_safe
  end

  def admin_page_level_indicator(level)
    (level + 1).times.collect{}.join('&mdash; ').html_safe
  end

  def admin_navbar_class
    return unless (@page && @page.statusable?)

    # if @page.scheduled?
    #   'bg-info'
    # elsif !@page.published?
    #   'bg-warning'
    # end

    !@page.published?
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
    record.try(:display_name).presence || record.try(:title).presence || record.try(:name).presence
  end

  def admin_header_tag(record, &block)
    record = record.first if record.respond_to?(:join)
    content_tag :div, capture(&block), class: "admin-header", data: {
      record_type: record&.class&.model_name&.singular,
      record_id: record.try(:id)
    }
  end

  def back_button(default_url)
    if request.referer.present?
      request.referer
    else
      default_url
    end
  end

  def jquery_include_tag
    if Rails.env.production?
      jquery_url = 'https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js'
    else
      jquery_url = 'forest/lib/jquery-3.3.1.min'
    end
    javascript_include_tag jquery_url, data: { turbolinks_eval: false, turbolinks_suppress_warning: true }
  end
end
