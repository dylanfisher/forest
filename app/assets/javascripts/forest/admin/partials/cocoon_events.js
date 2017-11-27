$(document).on('cocoon:after-insert', '.cocoon', function(e) {
  $(document).trigger( 'app:block-slot-after-insert', $(this) );
});
