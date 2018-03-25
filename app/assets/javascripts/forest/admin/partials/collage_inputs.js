// Collage inputs

(function() {
  var collageItemSelector = '.collage-input__item';
  var totalGridColumnNumber = 12;

  var updateZIndexes = function($canvas) {
    var $items = $canvas.find(collageItemSelector);

    for ( var i = 0; i < $items.length; i++ ) {
      var $highestEl;
      var maxZ = -Infinity;

      $items.each(function() {
        var z = parseInt( $(this).css('zIndex') ) || 0;

        if ( maxZ < z ) {
          $highestEl = $(this);
          maxZ = z;
        }
      });

      $highestEl.css({ zIndex: -$items.length + i });
    }

    $items.each(function(index) {
      var $item = $(this);
      var zIndex = Math.abs( parseInt( $item.css('zIndex') ) || 0 );
      var $inputZIndex = $item.find('.collage-input__input--z-index');

      $item.css({ zIndex: zIndex });
      $inputZIndex.val( zIndex );
    });
  };

  var updateInputValues = function(ui) {
    var $item = ui.helper.closest(collageItemSelector);
    var $image = $item.find('img');
    var $canvas = $item.closest('.collage-input__canvas');
    var $collage = $canvas.closest('.collage');
    var $items = $canvas.find(collageItemSelector);
    var canvasWidth = $canvas.width();
    var canvasHeight = $canvas.height();
    var imageWidth = $image.width();
    var imageHeight = $image.height();
    var itemPosition = $item.position();

    // Inputs
    var $inputLeft = $item.find('.collage-input__input--position-left');
    var $inputTop = $item.find('.collage-input__input--position-top');
    var $inputItemWidth = $item.find('.collage-input__input--item-width');
    var $inputItemHeight = $item.find('.collage-input__input--item-height');

    $item.css({ width: '', height: '' });

    updateZIndexes( $canvas );

    $inputLeft.val( itemPosition.left / canvasWidth * 100 );
    $inputTop.val( itemPosition.top / canvasHeight * 100 );
    $inputItemWidth.val( imageWidth / canvasWidth * 100 );
    $inputItemHeight.val( imageHeight / canvasHeight * 100 );
  };

  var updateCanvasInputValues = function(ui) {
    var $canvas = ui.helper;
    var $collage = $canvas.closest('.collage');
    var canvasWidth = $canvas.width();
    var canvasHeight = $canvas.height();
    var $inputCanvasHeightRatio = $collage.find('.collage-input__input--height-ratio');

    console.log('canvasWidth', canvasWidth);
    console.log('canvasHeight', canvasHeight);

    $inputCanvasHeightRatio.val( canvasHeight / canvasWidth * 100 );
  };

  var setMaxZIndexForItem = function($item) {
    var $canvas = $item.closest('.collage-input__canvas');
    var $items = $canvas.find(collageItemSelector);
    var zIndex = parseInt( $item.css('zIndex') ) || 0;
    var zIndexArray = [];

    $items.each(function() {
      var thisZIndex = parseInt( $(this).css('zIndex') ) || 0;
      zIndexArray.push( thisZIndex );
    });

    var largestZIndex = Math.max.apply( null, zIndexArray );

    $item.css({ zIndex: largestZIndex + 1 });
  };

  var resizableCanvasOptions = {
    handles: 's',
    stop: function(event, ui) {
      updateCanvasInputValues(ui);
    }
  };

  var resizableImageOptions = {
    aspectRatio: true,
    stop: function(event, ui) {
      updateInputValues(ui);
    }
  };

  var draggableOptions = {
    containment: 'parent',
    start: function(event, ui) {
      setMaxZIndexForItem(ui.helper);
    },
    stop: function(event, ui) {
      updateInputValues(ui);
    }
  };

  $(document).on('turbolinks:load', function() {
    var $canvases = $('.collage-input__canvas');

    $canvases.each(function() {
      var $canvas = $(this);
      var canvasId = '#' + $canvas.attr('id');

      $canvas.imagesLoaded(function() {
        var $items = $canvas.find(collageItemSelector);
        var $images = $items.find('img');

        $canvas.resizable(resizableCanvasOptions);
        console.log('$canvas', $canvas);
        $canvas.css({ height: $canvas.outerHeight(), paddingBottom: '' });

        $items.draggable(draggableOptions);
        $images.resizable(resizableImageOptions);
        $images.resizable('option', 'containment', canvasId);

        $canvas.addClass('initialized');
      });
    });
  });

  $(document).on('cocoon:after-insert', '.collage-input__canvas', function(e, insertedItem) {
    var $item = $(insertedItem);
    var $mediaGalleryChooserButton = $item.find('.media-item-chooser__button');
    var $collage = $item.closest('.collage');
    var $canvas = $collage.find('.collage-input__canvas');
    var canvasId = '#' + $canvas.attr('id');

    $mediaGalleryChooserButton.trigger('click');

    $(document).one('forest:update-media-gallery-preview.collageInput', function(e, insertedMediaItem) {
      var $newItem = $(insertedMediaItem).closest(collageItemSelector);
      var $newImage = $newItem.find('img');

      setMaxZIndexForItem($newItem);

      $newItem.css({ top: '50%', left: '50%' });

      $newItem.imagesLoaded(function() {
        $newItem.draggable(draggableOptions)
        $newImage.resizable(resizableImageOptions);
        $images.resizable('option', 'containment', canvasId);
      });

      $mediaGalleryChooserButton.remove();
    });
  });

})();
