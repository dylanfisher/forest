// Sortable galleries

(function() {
  var init = function() {
    var $galleries = $('.media-gallery-preview');

    $galleries.each(function() {
      var $gallery = $(this);
      var $wrapper = $gallery.closest('.gallery');
      var $hiddenGallerySelect = $wrapper.find('.gallery__input');

      $gallery.sortable({
        items: '.media-item--grid',
        containment: $gallery,
        tolerance: 'pointer',
        placeholder: 'ui-state-highlight col-xs-4 col-sm-3 col-md-2',
        scroll: false
      });

      if ( $hiddenGallerySelect.length ) {
        $gallery.on('sortupdate.sortable', function() {
          calculatePositions( $wrapper );
        });
      }
    });

    function calculatePositions($wrapper) {
      var $gallery = $wrapper.find('.media-gallery-preview');
      var $galleryItems = $gallery.children();
      var $hiddenGallerySelect = $wrapper.find('.gallery__input');

      $galleryItems.each(function(index) {
        var itemId = $(this).find('[data-media-item-id]').attr('data-media-item-id');

        $hiddenGallerySelect.find('option[value="' + itemId + '"]').appendTo( $hiddenGallerySelect );
      });
    }
  };

  App.pageLoad.push(function() {
    init();
  });

  $(document).on('forest:block-slot-after-insert', function() {
    init();
  });
})();
