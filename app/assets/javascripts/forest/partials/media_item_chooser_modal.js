$.fn.modal.Constructor.prototype._enforceFocus = function() {};

// TODO: refactor this whole file

$.fn.modal.Constructor.prototype.enforceFocus = function() {};

App.MediaItemChooser = {
  instances: [],
  initialize: function($elements) {
    var that = this;

    $elements.each(function() {
      var $element = $(this);
      var ajaxUrl = $element.attr('data-media-items-path');
      var xhr;

      that.instances.push( $element );

      $element
        .on('show.bs.modal', function(e) {
          var $modalBody = $element.find('.modal-body');

          if ( $modalBody.find('.media-library').length ) {
            App.InfiniteLoader.initialize( $element.find('[data-infinite-load]'), { $scrollListener: $element.find('.modal-body') } );
          } else {
            $.ajax(ajaxUrl)
              .done(function(data) {
                $modalBody.html( $(data).find('.media-library') );
                App.InfiniteLoader.initialize( $element.find('[data-infinite-load]'), { $scrollListener: $element.find('.modal-body') } );
              }).fail(function() {
                var error = 'Unable to fetch media items index.';
                console.warn(error);
                $modalBody.html(error);
              });
          }
        })
        .on('shown.bs.modal', function() {
          $(document).trigger('forest:show-media-item-chooser');

          var $modalBody = $element.find('.modal-body');
          var lastSearchValue;
          var $loadingIndicator = $('#media-item-chooser__modal-title__loading-indicator');

          $(document).on('keydown.mediaItemModalSearch', '#media_item_modal_fuzzy_search', function(e) {
            if ( e.which == 13 ) e.preventDefault();
          });

          $(document).on('change.mediaItemModalSearch keyup.mediaItemModalSearch', '#media_item_modal_fuzzy_search', $.debounce(300, function(e) {
            var $input = $(this);
            var searchValue = $input.val();

            if ( searchValue == lastSearchValue ) {
              return;
            }

            lastSearchValue = searchValue;

            $loadingIndicator.html('<span class="glyphicon glyphicon-hourglass"></span> Loading...');

            xhr = $.ajax({
                url: ajaxUrl,
                type: 'GET',
                data: {
                  fuzzy_search: searchValue
                }
              })
              .done(function(data) {
                $modalBody.html( $(data).find('.media-library') );
                App.InfiniteLoader.initialize( $element.find('[data-infinite-load]'), { $scrollListener: $element.find('.modal-body') } );
              }).fail(function() {
                var error = 'Unable to fetch media items index.';
                console.warn(error);
                $modalBody.html(error);
              }).always(function() {
                $loadingIndicator.empty();
              });
          }));
        })
        .on('hide.bs.modal', function() {
          if ( xhr ) xhr.abort();
          that.destroyModal();
        })
        .on('hidden.bs.modal', function() {
          $('.media-item-chooser .media-library-link--selected').removeClass('media-library-link--selected');
        });
    });
  },
  destroyModal: function() {
    for ( var i = this.instances.length - 1; i >= 0; i-- ) {
      App.InfiniteLoader.unbindScroll( this.instances[i] );
    }
    $('.media-item-chooser__button--active').removeClass('media-item-chooser__button--active');
    $(document).off('change.mediaItemModalSearch keyup.mediaItemModalSearch keydown.mediaItemModalSearch');
  },
  createThumbnail: function(id, url) {
    return '<div class="media-item--grid mb-3 col-xs-4 col-sm-3 col-md-2">' +
            '<div class="media-item--grid__image background-image-contain square-image rounded-lg " style="background-image: url(' + url + ')" data-media-item-id="' + id + '" data-media-item-url="' + url + '"></div>' +
            '<div class="media-item--grid__buttons">' +
              '<div class="media-item__button media-item--grid__button__remove glyphicon glyphicon-remove"></div>' +
            '</div>' +
          '</div>';
  },
  updateSelectedGalleryItems: function($gallery) {
    if ( !$gallery ) return;

    var thumbnailIds = [];
    var $preview = $gallery.find('.media-gallery-preview');
    var $input = $gallery.find('.gallery__input');

    $preview.find('[data-media-item-id]').each(function() {
      var id = $(this).attr('data-media-item-id');

      thumbnailIds.push(id);
    });

    $input.empty();

    for ( var i = 0; i < thumbnailIds.length; i++ ) {
      $input.append('<option value="' + thumbnailIds[i] + '" selected="selected">');
    }
  }
};

App.pageLoad.push(function() {
  App.MediaItemChooser.initialize( $('.media-item-chooser') );
});

$(document).on('click', '[data-media-item-input]', function() {
  // TODO: refactor this
  App.MediaItemChooser.scope = $(this);
  App.MediaItemChooser.inputSelector = $(this).attr('data-media-item-input');
  App.MediaItemChooser.input = false;
  App.MediaItemChooser.preview = false;
  App.MediaItemChooser.toPath = $(this).hasClass('media-item-chooser-to-path');
  App.MediaItemChooser.multiple = $(this).attr('data-multiple') == 'true';
});

$(document).on('click', '.media-item-chooser .media-library-link', function(e) {
  e.preventDefault();

  var $wrapper = $('.media-item-chooser__button--active').closest('.media-item-chooser-to-path');

  if ( !$wrapper.length ) {
    $wrapper = $('.media-item-chooser__button--active').closest('.image');
  }

  var id = $(this).attr('data-media-item-id');
  var imageUrl = $(this).attr('data-image-url-large');
  var value = App.MediaItemChooser.toPath ? imageUrl : id;
  var $removeButton = $(this).closest('.image').find('.media-item-chooser__remove-image');

  if ( !$removeButton.length ) {
    $removeButton = App.MediaItemChooser.scope.closest('.image').find('.media-item-chooser__remove-image');
  }

  if ( App.MediaItemChooser.inputSelector ) {
    if ( App.MediaItemChooser.toPath ) {
      App.MediaItemChooser.input = App.MediaItemChooser.scope.closest('.media-item-to-path-parent').find( App.MediaItemChooser.inputSelector );
    } else {
      App.MediaItemChooser.input = App.MediaItemChooser.scope.closest('.gallery, .image, .collage').find( App.MediaItemChooser.inputSelector );
    }
    App.MediaItemChooser.preview = App.MediaItemChooser.scope.closest('.gallery, .image, .collage').find( App.MediaItemChooser.inputSelector + '_preview' );

    if ( App.MediaItemChooser.multiple ) {
      // Multiple upload
      $(this).addClass('media-library-link--selected');
    } else {
      // Single item
      App.MediaItemChooser.input.val( value );

      if ( App.MediaItemChooser.preview.length )  {
        App.MediaItemChooser.preview.removeClass('d-none').attr('src', imageUrl);
        $removeButton.removeClass('d-none');
      }

      $(this).closest('.modal').modal('hide');
    }
  }

  $(document).trigger('forest:update-media-gallery-preview', [ App.MediaItemChooser.preview ]);
});

$(document).on('click.mediaItemChooser', '.media-library-link--selected', function() {
  $(this).removeClass('media-library-link--selected');
});

$(document).on('click.mediaItemChooser', '.media-item-chooser__select-button', function() {
  var $gallery = App.MediaItemChooser.preview.closest('.gallery, .collage');
  var $selected = $('.media-item-chooser .media-library-link--selected');
  var thumbnails = [];
  var $existingThumbnails = $gallery.find('.media-library-image');
  var existingThumbnailIds = $existingThumbnails.map(function() {
    return parseInt( $(this).attr('data-media-item-id') );
  });

  $selected.each(function() {
    var id = parseInt( $(this).attr('data-media-item-id') );
    var url = $(this).attr('data-image-url-large');
    var $thumbnail = $( App.MediaItemChooser.createThumbnail(id, url) );

    if ( $.inArray(id, existingThumbnailIds) == -1 ) {
      thumbnails.push($thumbnail);
    }
  });

  $('.modal.media-item-chooser').modal('hide');
  if ( App.MediaItemChooser.preview.length ) {
    if ( App.MediaItemChooser.preview.closest('.media-gallery-preview-wrapper').hasClass('media-gallery-preview-wrapper--no-images') ) {
      App.MediaItemChooser.preview.closest('.media-gallery-preview-wrapper').removeClass('media-gallery-preview-wrapper--no-images').addClass('media-gallery-preview-wrapper--has-images');
      App.MediaItemChooser.preview.empty();
    }

    App.MediaItemChooser.preview.append( thumbnails );
  }

  App.MediaItemChooser.updateSelectedGalleryItems( $gallery );
});

$(document).on('click.mediaItemChooser', '.media-item-chooser__button, [data-media-item-input]', function() {
  $(this).addClass('media-item-chooser__button--active');
});

$(document).on('click', '.media-item-chooser__remove-image', function() {
  var $wrapper = $(this).closest('.image');
  var $image = $wrapper.find('.media-item-chooser__image');
  var $button = $wrapper.find('.media-item-chooser__button');
  var $input = $wrapper.find( $button.attr('data-media-item-input') );
  var $toPathInput = $wrapper.closest('.media-item-to-path-parent').find('.media-item-to-path-target');

  $image.attr('src', '').attr('alt', '').addClass('d-none');
  $input.val('');
  $(this).addClass('d-none');

  if ( $toPathInput.length ) {
    $toPathInput.val('');
  }
});

$(document).on('click', '.media-item--grid__button__remove', function() {
  var $gallery = $(this).closest('.gallery, .collage');
  var $mediaItem = $(this).closest('.media-item--grid');

  $mediaItem.remove();

  App.MediaItemChooser.updateSelectedGalleryItems( $gallery );
});

$(document).on('click', '.media-gallery-preview', function(e) {
  e.preventDefault();
});

$(document).on('click', '.media-item__button[data-path]', function() {
  var url = $(this).attr('data-path');

  window.open( url, '_blank' );
  window.focus();
});

$(document).on('click', '.media-gallery-preview', function(e) {
  e.preventDefault();
});
