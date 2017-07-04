$(document).on('change', 'select[name*="[status]"]', function(e) {
  var $select = $(this);
  var value = $select.val();

  if ( value == 'scheduled' ) {
    // Show date picker
  } else {
    // Hide date picker
  }
});
