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

  def table_thumbnail(media_item)
    if media_item.try(:video?)
      content_tag :div, class: 'table-thumbnail' do
        if media_item.try(:vimeo_video?)
          if media_item.vimeo_video_thumbnail.present?
            image_tag media_item.vimeo_video_thumbnail
          end
        end
      end
    elsif media_item&.attachment.present?
      content_tag :div, class: 'table-thumbnail' do
        image_tag media_item.attachment_url(:thumb)
      end
    end
  end

  def table_sort_supported?(records:)
    return if controller_name != records.klass.model_name.route_key

    allow_sort_by_position = false
    order_value = records.order_values.first
    if order_value.is_a?(String)
      allow_sort_by_position = order_value.include?('position')
    elsif order_value.is_a?(Arel::Nodes::Ascending)
      allow_sort_by_position = order_value.try(:expr).try(:name) == 'position'
    end
    allow_sort_by_position
  end

  def sortable_table_attributes(records:, pagy:)
    return {} unless table_sort_supported?(records: records)

    { sortable_table: true, update_table_position_path: admin_position_updater_path, table_record_offset: pagy.offset, resource: records.klass.name }
  end

  def sortable_row_attributes(record)
    { sortable_row: true, record_id: record.id }
  end

  def sortable_table_field(records:, position:, **options)
    if table_sort_supported?(records: records)
      options.reverse_merge!(title: 'Drag to reorder')
      content_tag :div, "#{content_tag(:span, position, class: 'table-position-label')} #{hidden_field_tag(:forest_sortable_field_position, position, id: nil)}".html_safe, class: "table-position-field #{options.delete(:class)}", **options
    else
      if controller_name != records.klass.model_name.route_key
        title = 'Position can only be updated when viewing records within the resource\'s main table view.'
      else
        title = 'Position can only be updated when records are ordered ascending by position'
      end
      options.reverse_merge!(title: title)
      content_tag :div, position, class: "table-position-field table-position-field--disabled #{options.delete(:class)}", **options
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

  def bootstrap_icon(icon_name, options = {})
    options[:class] = "#{options[:class]} bootstrap-icon"
    embedded = options.delete(:embedded)
    if embedded
      forest_embedded_svg("bootstrap/#{icon_name}.svg", class: "bi bi-#{icon_name}")
    else
      image_tag("bootstrap/#{icon_name}.svg", **options)
    end
  end
end
