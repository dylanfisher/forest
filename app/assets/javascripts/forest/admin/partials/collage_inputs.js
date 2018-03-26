// Collage inputs

(function() {
  var collageCanvasSelector = '.collage-input__canvas';
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
    var $canvas = $item.closest(collageCanvasSelector);
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

  var setRelativeImageSizes = function($canvas) {
    var canvasWidth = $canvas.width();
    var $items = $canvas.find(collageItemSelector);

    $items.each(function() {
      var $item = $(this);
      var itemWidth = $item.width();
      var ratio = itemWidth / canvasWidth;

      $item.attr( 'data-item-width-to-canvas-width-ratio', ratio );
    });
  };

  var updateCanvasInputValues = function(ui) {
    var $canvas = ui.helper;
    var $collage = $canvas.closest('.collage');
    var $inputCanvasHeightRatio = $collage.find('.collage-input__input--height-ratio');

    $canvas.attr( 'data-original-height-ratio', getItemRatio($canvas) );
    $inputCanvasHeightRatio.val( getItemRatio($canvas) );
  };

  var setMaxZIndexForItem = function($item) {
    var $canvas = $item.closest(collageCanvasSelector);
    var $items = $canvas.find(collageItemSelector);
    var zIndex = parseInt( $item.css('zIndex') ) || 0;
    var zIndexArray = [];

    $items.each(function() {
      var thisZIndex = parseInt( $(this).css('zIndex') ) || 0;
      zIndexArray.push( thisZIndex );
    });

    var largestZIndex = Math.max.apply( null, zIndexArray );

    $item.css({ zIndex: largestZIndex + 1 });

    updateZIndexes( $canvas );
  };

  var getItemRatio = function($item) {
    return $item.height() / $item.width() * 100;
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
      var $item = ui.helper.closest(collageItemSelector);
      var $canvas = $item.closest(collageCanvasSelector);

      updateInputValues(ui);
      setRelativeImageSizes($canvas);
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

  $(document).on('turbolinks:load forest:block-slot-after-insert', function() {
    var $canvases = $('.collage-input__canvas:not(.pre-initialized)');

    if ( !$canvases.length ) return;

    $canvases.addClass('pre-initialized');

    $canvases.each(function() {
      var $canvas = $(this);
      var canvasId = '#' + $canvas.attr('id');

      $canvas.css({ height: $canvas.outerHeight(), paddingBottom: '' });
      $canvas.attr('data-original-height-ratio', getItemRatio($canvas) );

      $canvas.imagesLoaded(function() {
        var $items = $canvas.find(collageItemSelector);
        var $images = $items.find('img');

        $canvas.resizable(resizableCanvasOptions);

        $items.draggable(draggableOptions);
        $images.resizable(resizableImageOptions);
        $images.resizable('option', 'containment', canvasId);

        setRelativeImageSizes($canvas);

        $canvas.addClass('initialized');
      });

      $(document).one('turbolinks:before-cache', function() {
        $canvas.resizable('destroy');
        $items.draggable('destroy');
        $images.resizable('destroy');
      });
    });

    $(window).on('resize.collageInput', $.debounce(250, function() {
      $canvases.each(function() {
        var $canvas = $(this);
        var newCanvasWidth = $canvas.width();
        var originalRatio = parseFloat( $canvas.attr('data-original-height-ratio') ) / 100;
        var newHeight = $canvas.width() * originalRatio;
        var $items = $canvas.find(collageItemSelector);

        $canvas.css({ height: newHeight });

        $items.each(function() {
          var $item = $(this);
          var $image = $item.find('img');
          var $uiWrapper = $item.find('.ui-wrapper');
          var itemWidth = $item.width();
          var originalItemRatio = $item.attr('data-item-width-to-canvas-width-ratio');
          var newWidth = newCanvasWidth * originalItemRatio;
          var imageWidth = $image.width();
          var imageHeight = $image.height();
          var imageRatio = imageHeight / imageWidth;
          var newHeight = newWidth * imageRatio;

          $item.add($uiWrapper)
               .add($image)
               .css({ width: newWidth, height: newHeight });
        });
      });
    }));

    $(document).one('turbolinks:before-cache', function() {
      $(window).off('resize.collageInput');
    });
  });

  $(document).on('cocoon:after-insert', collageCanvasSelector, function(e, insertedItem) {
    var $item = $(insertedItem);
    var $mediaGalleryChooserButton = $item.find('.media-item-chooser__button');
    var $collage = $item.closest('.collage');
    var $canvas = $collage.find(collageCanvasSelector);
    var canvasId = '#' + $canvas.attr('id');

    $mediaGalleryChooserButton.trigger('click');

    $(document).one('forest:update-media-gallery-preview.collageInput', function(e, insertedMediaItem) {
      var $newItem = $(insertedMediaItem).closest(collageItemSelector);
      var $newImage = $newItem.find('img');
      var $emptyCanvasMessage = $canvas.find('.collage-input__empty-canvas-message');

      setMaxZIndexForItem($newItem);
      $newImage.css({ width: $canvas.width() / 3 });

      $newItem.imagesLoaded(function() {
        $newItem.draggable(draggableOptions)
                .css({
                  top: 'calc(50% - ' + ( $newImage.height() / 2 ) + 'px)',
                  left: 'calc(50% - ' + ( $newImage.width() / 2 ) + 'px)',
                });
        $newImage.resizable(resizableImageOptions);
        $newImage.resizable('option', 'containment', canvasId);
      });

      $mediaGalleryChooserButton.remove();

      if ( $emptyCanvasMessage.length ) $emptyCanvasMessage.remove();

      $(document).one('turbolinks:before-cache', function() {
        $newItem.draggable('destroy');
        $newImage.resizable('destroy');
      });
    });
  });

  $(document).on('click', collageItemSelector, function() {
    setMaxZIndexForItem( $(this) );
  });
})();
