// Collage inputs

(function() {
  var collageCanvasSelector = '.collage-input__canvas';
  var collageItemSelector = '.collage-input__item';
  var totalGridColumnNumber = 12;
  var uiInteractionInProgress = false;

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

  var updateInputValues = function($item) {
    var $image = $item.find('.media-item-chooser__image:visible');
    var isTextBox = $item.hasClass('collage-input__item--text-box');
    var $textBox = $item.find('.collage-input__input--text-box:visible');
    var $canvas = $item.closest(collageCanvasSelector);
    var $collage = $canvas.closest('.collage');
    var $items = $canvas.find(collageItemSelector);
    var canvasWidth = $canvas.width();
    var canvasHeight = $canvas.height();
    var imageWidth = $image.width();
    var imageHeight = $image.height();
    var textBoxWidth = $textBox.width();
    var textBoxHeight = $textBox.height();
    var itemPosition = $item.position();
    var imageOrTextBoxWidth = imageWidth;
    var imageOrTextBoxHeight = imageHeight;

    if ( isTextBox ) {
      imageOrTextBoxWidth = textBoxWidth;
      imageOrTextBoxHeight = textBoxHeight;
    }

    // Inputs
    var $inputLeft = $item.find('.collage-input__input--position-left');
    var $inputTop = $item.find('.collage-input__input--position-top');
    var $inputItemWidth = $item.find('.collage-input__input--item-width');
    var $inputItemHeight = $item.find('.collage-input__input--item-height');

    if ( !isTextBox ) {
      $item.css({ width: '', height: '' });
    }

    updateZIndexes( $canvas );

    $inputLeft.val( itemPosition.left / canvasWidth * 100 );
    $inputTop.val( itemPosition.top / canvasHeight * 100 );
    $inputItemWidth.val( imageOrTextBoxWidth / canvasWidth * 100 );
    $inputItemHeight.val( imageOrTextBoxHeight / canvasHeight * 100 );
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

  var updateCanvasInputValues = function($canvas) {
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
    start: function(event, ui) {
      uiInteractionInProgress = true;
    },
    stop: function(event, ui) {
      var $canvas = ui.helper;
      var $items = $canvas.find(collageItemSelector);

      setRelativeImageSizes($canvas);
      updateCanvasInputValues($canvas);

      $items.each(function() {
        var $item = $(this);

        updateInputValues($item);
      });

      uiInteractionInProgress = false;
    }
  };

  var resizableImageOptions = {
    aspectRatio: true,
    start: function(event, ui) {
      uiInteractionInProgress = true;
    },
    stop: function(event, ui) {
      var $item = ui.helper.closest(collageItemSelector);
      var $canvas = $item.closest(collageCanvasSelector);

      updateInputValues($item);
      setRelativeImageSizes($canvas);

      uiInteractionInProgress = false;
    }
  };

  var draggableOptions = {
    containment: 'parent',
    start: function(event, ui) {
      uiInteractionInProgress = true;
      setMaxZIndexForItem(ui.helper);
    },
    stop: function(event, ui) {
      var $item = ui.helper.closest(collageItemSelector);

      updateInputValues($item);

      uiInteractionInProgress = false;
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

      updateCanvasInputValues($canvas);

      $canvas.imagesLoaded(function() {
        var $items = $canvas.find(collageItemSelector);
        var $images = $items.find('.media-item-chooser__image');

        $canvas.resizable(resizableCanvasOptions);

        $items.draggable(draggableOptions);
        $images.resizable(resizableImageOptions);
        $images.resizable('option', 'containment', canvasId);

        setRelativeImageSizes($canvas);

        $canvas.addClass('initialized');

        $(document).one('turbolinks:before-cache', function() {
          $items.draggable('destroy');
          $images.resizable('destroy');
        });
      });

      $(document).one('turbolinks:before-cache', function() {
        $canvas.resizable('destroy')
               .removeClass('pre-initialized');
      });
    });

    $(window).on('resize.collageInput', $.debounce(250, function() {
      if ( uiInteractionInProgress ) return;

      $canvases.each(function() {
        var $canvas = $(this);
        var newCanvasWidth = $canvas.width();
        var originalRatio = parseFloat( $canvas.attr('data-original-height-ratio') ) / 100;
        var newHeight = $canvas.width() * originalRatio;
        var $items = $canvas.find(collageItemSelector);

        $canvas.css({ height: newHeight });

        $items.each(function() {
          var $item = $(this);
          var $image = $item.find('.media-item-chooser__image:visible');
          var isTextBox = $item.hasClass('collage-input__item--text-box');
          var $textBox = $item.find('.collage-input__input--text-box:visible');
          var $uiWrapper = $item.find('.ui-wrapper');
          var itemWidth = $item.width();
          var originalItemRatio = $item.attr('data-item-width-to-canvas-width-ratio');
          var newWidth = newCanvasWidth * originalItemRatio;
          var imageWidth = $image.width();
          var imageHeight = $image.height();
          var imageRatio = imageHeight / imageWidth;
          var textBoxWidth = $textBox.width();
          var textBoxHeight = $textBox.height();
          var textBoxRatio = textBoxHeight / textBoxWidth;
          var newHeight = newWidth * imageRatio;
          var newTextBoxHeight = newWidth * textBoxRatio;

          if ( isTextBox ) {
            newHeight = newTextBoxHeight;
          }

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
    var isTextBox = $item.hasClass('collage-input__item--text-box');
    var $mediaGalleryChooserButton = $item.find('.media-item-chooser__button');
    var $collage = $item.closest('.collage');
    var $canvas = $collage.find(collageCanvasSelector);
    var canvasId = '#' + $canvas.attr('id');

    $mediaGalleryChooserButton.trigger('click');

    $(document).one('forest:update-media-gallery-preview.collageInput', function(e, insertedMediaItem) {
      var $newItem = $(insertedMediaItem).closest(collageItemSelector);
      var $newImage = $newItem.find('.media-item-chooser__image');
      var $emptyCanvasMessage = $canvas.find('.collage-input__empty-canvas-message');

      setMaxZIndexForItem($newItem);
      $newImage.css({
        opacity: 0,
        width: $canvas.width() / 3
      });

      $newItem.imagesLoaded(function() {
        $newItem.draggable(draggableOptions)
                .css({
                  top: 'calc(50% - ' + ( $newImage.height() / 2 ) + 'px)',
                  left: 'calc(50% - ' + ( $newImage.width() / 2 ) + 'px)',
                });
        $newImage.resizable(resizableImageOptions)
                 .css({ opacity: 1 });
        $newImage.resizable('option', 'containment', canvasId);

        updateInputValues($newItem);

        $(document).one('turbolinks:before-cache', function() {
          $newItem.draggable('destroy');
          $newImage.resizable('destroy');
        });
      });

      $mediaGalleryChooserButton.remove();

      if ( $emptyCanvasMessage.length ) $emptyCanvasMessage.remove();
    });

    if ( isTextBox ) {
      $(document).trigger('forest:update-media-gallery-preview.collageInput', [$item]);
    }
  });

  $(document).on('mouseup.collageInput', '.collage-input__input--text-box', function(e) {
    var $item = $(this).closest('.collage-input__item');

    updateInputValues($item);
  });

  $(document).on('click', collageItemSelector, function() {
    setMaxZIndexForItem( $(this) );
  });
})();
