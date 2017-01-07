module Forest
  module StatusIndicatorHelper
    def status_indicator(record)
      content_tag(:span, '',
        class: "status-indicator status-indicator--#{record.status}",
        title: "Page status: #{t(record.status, scope: [record.model_name.singular, :status])}")
    end
  end
end
