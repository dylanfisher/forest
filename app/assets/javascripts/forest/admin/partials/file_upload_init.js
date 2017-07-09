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
        var previewLink = $('.template-download .preview a').attr('href');
        var previewImageUrl = $('.template-download .preview img').attr('src');
        var previewHTML = '<div class="col-xs-4 col-sm-3 col-md-2"><a class="media-library-link" href="' + previewLink + '"><div class="media-library-image img-rounded" style="background-image: url(' + previewImageUrl + ')"></div></a></div>';

        $('.template-download').remove();
        $(previewHTML).prependTo( $('.media-library [data-infinite-load]') );
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
