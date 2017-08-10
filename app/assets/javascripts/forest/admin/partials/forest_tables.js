// Forest tables

$(document).on('mouseenter', '.forest-table tbody tr', function() {
  var $row = $(this);

  $row.addClass('active');

  $(document).one('turbolinks:before-cache.forestTables', function() {
    $row.removeClass('active');
  });
});

$(document).on('mouseleave', '.forest-table tbody tr', function() {
  var $row = $(this);

  $row.removeClass('active');
});

$(document).on('click', '.forest-table tbody tr', function(e) {
  var $row = $(this);

  if ( !$(e.target).closest('a').length ) {
    var $button = $row.find('a.forest-table__link:first');

    if ( !$button.length ) {
      $button = $row.find('a.btn-primary:first');
    }

    var url = $button.attr('href');

    if ( url ) {
      Turbolinks.visit(url);
    }
  }
});
