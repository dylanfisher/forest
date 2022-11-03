module StatusIndicatorHelper
  def status_indicator(record, options = {})
    default_record_status = t(record.status, scope: [:forest, :admin, :page, :status])
    content_tag(:span, '',
      class: "status-indicator status-indicator--#{record.status} #{options.delete(:class)}",
      title: "Record status: #{t(record.status, scope: [:forest, :admin, record.model_name.singular, :status], default: default_record_status)}",
      **options)
  end
end
