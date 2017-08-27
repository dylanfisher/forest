// Sortable galleries

$(document).on('turbolinks:load app:block-slot-after-insert', function() {
  var $galleries = $('.media-gallery-preview');

  $galleries.each(function() {
    var $gallery = $(this);

    $gallery.sortable({
      items: '.media-item--grid',
      containment: $gallery,
      tolerance: 'pointer',
      placeholder: 'sortable-placeholder col-xs-4 col-sm-3 col-md-2'
    });
  });

  $(document).one('turbolinks:before-cache.sortableGalleries', function() {
    $galleries.each(function() {
      var $gallery = $(this);

      $gallery.sortable('destroy');
    });
  });
});
