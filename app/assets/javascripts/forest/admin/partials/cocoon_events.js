$(document).on('cocoon:after-insert', '.cocoon, .sortable-field-set', function(e) {
  $(document).trigger( 'forest:block-slot-after-insert', $(this) );
});
