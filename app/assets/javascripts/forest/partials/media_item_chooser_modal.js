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
          var $relatedTarget = $(e.relatedTarget);
          var mediaItemScope = $relatedTarget.attr('data-media-item-scope');
          var ajaxData = {};
          var refreshAjax = false;

          if ( App.MediaItemChooser.lastScope != mediaItemScope ) refreshAjax = true;
          App.MediaItemChooser.lastScope = mediaItemScope;

          if ( mediaItemScope ) ajaxData[mediaItemScope] = true;

          if ( !refreshAjax && $modalBody.find('.media-library').length ) {
            App.InfiniteLoader.initialize( $element.find('[data-infinite-load]'), { $scrollListener: $element.find('.modal-body') } );
          } else {
            $.ajax({
                url: ajaxUrl,
                data: ajaxData
              })
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

          $modalBody.shiftSelectable({
            items: '.media-library-link',
            trigger: 'click' ,
            triggerOnSelf: false
          });
        })
        .on('hide.bs.modal', function() {
          if ( xhr ) xhr.abort();
          that.destroyModal();
        })
        .on('hidden.bs.modal', function() {
          $('#media-item-chooser .media-library-link--selected').removeClass('media-library-link--selected');
        });
    });
  },
  destroyModal: function() {
    for ( var i = this.instances.length - 1; i >= 0; i-- ) {
      App.InfiniteLoader.unbindScroll( this.instances[i] );
    }
    $('.media-item-chooser__button--active').removeClass('media-item-chooser__button--active');
    $(document).off('change.mediaItemModalSearch keyup.mediaItemModalSearch keydown.mediaItemModalSearch click.markdownImageUpload');
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

App.MediaItemChooser.lastScope = undefined;

App.pageLoad.push(function() {
  App.MediaItemChooser.initialize( $('#media-item-chooser') );
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

$(document).on('click', '#media-item-chooser .media-library-link', function(e) {
  e.preventDefault();

  var $wrapper = $('.media-item-chooser__button--active').closest('.media-item-chooser-to-path');

  if ( !$wrapper.length ) {
    $wrapper = $('.media-item-chooser__button--active').closest('.image');
  }

  var $mediaLibraryLink = $(this);
  var id = $mediaLibraryLink.attr('data-media-item-id');
  var imageUrl = $mediaLibraryLink.attr('data-image-url-large');
  var videoUrl;

  if ( $mediaLibraryLink.attr('data-video-url') ) {
    videoUrl = $mediaLibraryLink.attr('data-video-url');
  }

  var value = App.MediaItemChooser.toPath ? imageUrl : id;
  var $removeButton = $mediaLibraryLink.closest('.image').find('.media-item-chooser__remove-image');
  var mediaItemEditPath = $mediaLibraryLink.attr('href');

  if ( App.MediaItemChooser.scope ) {
    var $scopedImageWrapper = App.MediaItemChooser.scope.closest('.image');
    var $buttonGroup = $scopedImageWrapper.find('.image__btn-group');
    var $editButton = $scopedImageWrapper.find('.media-item-chooser__edit-image');

    if ( !$removeButton.length ) {
      $removeButton = $scopedImageWrapper.find('.media-item-chooser__remove-image');
    }
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
      $mediaLibraryLink.addClass('media-library-link--selected');
    } else {
      // Single item
      var $previewWrapper = App.MediaItemChooser.preview.closest('.media-item-chooser__image-wrapper__inner')
      var $imageWrapper = App.MediaItemChooser.input.closest('.image-input__body');
      $imageWrapper.find('.media-item--grid__icon').remove();

      App.MediaItemChooser.input.val( value );

      if ( App.MediaItemChooser.preview.length )  {
        $previewWrapper.find('.media-item-chooser__temp-video').remove();

        if ( videoUrl ) {
          if ( App.MediaItemChooser.preview.hasClass('media-item-chooser__image--video') ) {
            App.MediaItemChooser.preview.removeClass('d-none').attr('src', videoUrl);
          } else {
            App.MediaItemChooser.preview.addClass('d-none');
            $previewWrapper.append('<video src="' + videoUrl + '" controls preload="metadata" class="media-item-chooser__temp-video media-item-chooser__image media-item-chooser__image--video mb-3 rounded cursor-pointer">');
          }
        } else {
          App.MediaItemChooser.preview.removeClass('d-none').attr('src', imageUrl);
        }

        $removeButton.removeClass('d-none');
        $editButton.removeClass('d-none');
      }

      $buttonGroup.removeClass('image__btn-group--blank-image');
      $editButton.attr('href', mediaItemEditPath);

      $mediaLibraryLink.closest('.modal').modal('hide');
    }
  }

  $(document).trigger('forest:update-media-gallery-preview', [ App.MediaItemChooser.preview ]);
});

$(document).on('click.mediaItemChooser', '.media-library-link--selected', function() {
  $(this).removeClass('media-library-link--selected');
});

$(document).on('click.mediaItemChooser', '.media-item-chooser__select-button', function() {
  var $gallery = App.MediaItemChooser.preview.closest('.gallery, .collage');
  var $selected = $('#media-item-chooser .media-library-link--selected');
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

  $('#media-item-chooser').modal('hide');
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
  var $removeButton = $(this);
  var $wrapper = $removeButton.closest('.image');
  var $image = $wrapper.find('.media-item-chooser__image');
  var $buttonGroup = $wrapper.find('.image__btn-group');
  var $button = $wrapper.find('.media-item-chooser__button');
  var $input = $wrapper.find( $button.attr('data-media-item-input') );
  var $toPathInput = $wrapper.closest('.media-item-to-path-parent').find('.media-item-to-path-target');
  var $editButton = $wrapper.find('.media-item-chooser__edit-image');

  $image.attr('src', '').attr('alt', '').addClass('d-none');
  $input.val('');
  $removeButton.addClass('d-none');
  $editButton.addClass('d-none');
  $buttonGroup.addClass('image__btn-group--blank-image');

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
