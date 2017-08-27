$(document).on('change', '.status-scheduler select[name*="[status]"]', function(e) {
  var $select = $(this);
  var $wrapper = $select.closest('.status-scheduler');
  var $datepicker = $wrapper.find('input[name$="[scheduled_date]"]');
  var $datepickerWrapper = $wrapper.find('.form-group[class*="_scheduled_date"]');
  var value = $select.val();

  if ( value == 'scheduled' ) {
    // Show date picker
    $datepickerWrapper.addClass('active');
    App.Datepicker.add( $datepicker );
  } else {
    // Hide date picker
    $datepickerWrapper.removeClass('active');
  }
});
