$(document).on('change', '#select_all', function() {
  var $checkbox = $(this);
  var $table = $checkbox.closest('table');
  var $checkboxes = $table.find('[name="selected[]"]');

  $checkboxes.prop( 'checked', $checkbox.is(':checked') );
});
