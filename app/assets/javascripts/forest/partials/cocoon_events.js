$(document).on('cocoon:after-insert', function(e, $insertedItem) {
  if ( $insertedItem.hasClass('block-slot-field-template-wrapper') ) return;

  $(document).trigger( 'forest:block-slot-after-insert', $insertedItem );
});
