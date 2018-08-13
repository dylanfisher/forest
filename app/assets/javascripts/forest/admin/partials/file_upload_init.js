App.FileUploader = {
  instances: [],
  initialize: function($fileuploads) {
    if ( !$fileuploads.length ) return;

    var that = this;

    $(document).one('turbolinks:before-cache.FileUploader', function() {
      that.teardown();
    });

    $(document).on('dragover.FileUploader dragenter.FileUploader', function() {
      $('html').addClass('fileupload-dragover');
    });

    $(document).on('dragleave.FileUploader dragend.FileUploader drop.FileUploader', function() {
      $('html').removeClass('fileupload-dragover');
    });

    $fileuploads.each(function() {
      var $fileupload = $(this);

      that.instances.push( $fileupload );

      $fileupload.fileupload({
        autoUpload: true,
        sequentialUploads: false,
      }).on('fileuploadstart', function (e) {
        $('#progress').removeClass('hidden').addClass('fade in');
      }).on('fileuploadprogressall', function (e, data) {
        var progress = parseInt( data.loaded / data.total * 100, 10 );

        $('#progress .progress-bar').css( 'width', progress + '%' );
      }).on('fileuploadcompleted', function(e, data) {
        var $table = $('.forest-table');
        var previewHTML;

        if ( $fileupload.hasClass('fileupload--media_item') ) {
          // Media items
          var previewLink = $('.template-download .preview a').attr('href');
          var fileId = data.result.files[0].id;
          var mediaItemName = data.result.files[0].name;
          var fileName = data.result.files[0].file_name;
          var previewImageUrl = $('.template-download .preview img').attr('src');
          // This previewHTML needs to match the _media_item_grid_layout.html.erb partial
          previewHTML = '<div class="media-item--grid col-xs-4 col-sm-3 col-md-2">\
                          <a class="media-library-link" href="' + previewLink + '" data-media-item-id="' + fileId + '" data-image-url="' + previewImageUrl + '" data-image-url-large="' + previewImageUrl + '">\
                            <div class="media-library-image img-rounded" style="background-image: url(' + previewImageUrl + ')">\
                              <div class="media-library-image__label small well" title="' + fileName + '">' + mediaItemName + '</div>\
                            </div>\
                          </a>\
                          <div class="media-item__buttons">\
                            <div class="media-item__button media-item__buttons__edit glyphicon glyphicon-pencil" data-path="/admin/media-items/' + fileId + '/edit"></div>\
                          </div>\
                        </div>';

          $('.template-download').remove();
          $(previewHTML).prependTo( $('.media-library [data-infinite-load]') );
        } else if ( $table.length ) {
          var columns = [];
          var $tableHeaders = $table.find('thead th');

          for ( var i = 0; i < data.result.files.length; i++ ) {
            var result = data.result.files[i];

            columns.push('<tr>');

            $tableHeaders.each(function() {
              var $header = $(this);
              var headerAttr = $header.attr('data-column');
              var columnValue = result[headerAttr];
              var colSpan = parseInt( $header.attr('colspan') );

              columns.push( '<td>' + columnValue + '</td>' );
            });

            for ( var ii = 0; ii < 3; ii++ ) {
              columns.push( '<td></td>' );
            }

            columns.push('</tr>');
          }

          $table.find('tbody').prepend( columns.join() );
        } else {
          console.warn('[Forest] Can\'t find suitable element to prepend file upload to.');
        }
      }).on('fileuploadstop', function(e, data) {
        $('#progress').addClass('hidden').removeClass('fade in');
      });
    });
  },
  teardown: function() {
    for ( var i = this.instances.length - 1; i >= 0; i-- ) {
      this.instances[i].fileupload('destroy');
    }
    this.instances = [];
    $('html').removeClass('fileupload-dragover');
    $(document).off('dragover.FileUploader dragenter.FileUploader dragleave.FileUploader dragend.FileUploader drop.FileUploader');
  }
};

App.pageLoad.push(function() {
  App.FileUploader.initialize( $('#fileupload') );
});
