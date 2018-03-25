// Collage inputs

$(document).on('turbolinks:load', function() {
  var $collages = $('.collage-input__canvas');
  var collageItemSelector = '.collage-input__item';

  var updateZIndexes = function($collage) {
    var $items = $collage.find(collageItemSelector);

    for ( var i = $items.length - 1; i >= 0; i-- ) {
      var $highestEl;
      var maxZ = -Infinity;

      $items.each(function() {
        var z = parseInt( $(this).css('zIndex') );
        if ( maxZ < z ) {
          $highestEl = $(this);
          maxZ = z;
        }
      });

      $highestEl.css({ zIndex: -$items.length + i });
    }
  }

  var updateInput = function($collage) {
    var $input = $collage.find('.collage-input__position-input');

    $input.val( JSON.stringify( inputData ) );
  }

  $collages.each(function() {
    var $collage = $(this);
    var $items = $collage.find(collageItemSelector);
    var options = {

    };

    $items.draggable(options);
  });
});
