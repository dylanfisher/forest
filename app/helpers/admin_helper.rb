module AdminHelper
  include Pagy::Frontend

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
        image_tag image.attachment_url(:thumb)
      end
    end
  end

  def forest_date(datetime)
    return if datetime.blank?
    datetime_format = datetime.is_a?(Date) ? '%m&#8209;%d&#8209;%Y' : '%m&#8209;%d&#8209;%Y %l:%M&nbsp;%p'
    datetime.strftime(datetime_format).html_safe
  end

  def admin_page_level_indicator(level)
    (level + 1).times.collect{}.join('&mdash; ').html_safe
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
    return unless record.present?
    if record.new_record?
      "New #{record.model_name.human}"
    else
      record.try(:display_name).presence || record.try(:title).presence || record.try(:name).presence || "#{record.model_name.human} #{record.id}"
    end
  end

  def admin_header_tag(record, &block)
    record = record.first if record.respond_to?(:join)
    content_tag :div, capture(&block), class: "admin-header mb-3", data: {
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

  def bootstrap_icon(icon_name)
    "<svg class='bi' style='width: 1.3em; height: 1.3em;' fill='currentColor'><use xlink:href='#{asset_path('bootstrap-icons.svg')}##{icon_name}'/></svg>".html_safe
  end
end
