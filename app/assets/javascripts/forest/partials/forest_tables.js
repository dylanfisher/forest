// Forest tables

$(document).on('mouseenter', '.forest-table tbody tr', function() {
  var $row = $(this);

  $row.addClass('active');
});

$(document).on('mouseleave', '.forest-table tbody tr', function() {
  var $row = $(this);

  $row.removeClass('active');
});

$(document).on('click', '.forest-table tbody tr', function(e) {
  var $row = $(this);

  if ( !$(e.target).closest('a, input').length ) {
    var $button = $row.find('a.forest-table__link:first');

    if ( !$button.length ) {
      $button = $row.find('a.btn-outline-secondary, a.btn-primary').first();
    }

    var url = $button.attr('href');

    if ( url ) {
      if ( e.metaKey || e.ctrlKey ) {
        window.open( url, '_blank' );
      } else if ( e.shiftKey ) {
        window.open( url, '_blank' );
        window.focus();
      } else {
        window.location = url;
      }
    }
  }
});
