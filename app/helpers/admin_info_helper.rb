module AdminInfoHelper
  def info_message(message)
    [
      '<div class="card">',
        '<div class="card-body text-muted">',
          bootstrap_icon('info-circle', class: 'mr-2', width: 18, style: 'margin-top: 2px;'),
          message,
        '</div>',
    '</div>'
    ].join.html_safe
  end
end
