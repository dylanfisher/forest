$(document).on('cocoon:after-insert', '.cocoon', function(e) {
  $(document).trigger( 'forest:block-slot-after-insert', $(this) );
});
