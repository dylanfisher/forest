module AdminInfoHelper
  def info_message(message)
    [
      '<div class="well">',
        '<div class="text-muted">',
          '<span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span> ',
          message,
        '</div>',
    '</div>'
    ].join.html_safe
  end
end
