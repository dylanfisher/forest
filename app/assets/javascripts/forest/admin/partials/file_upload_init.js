App.FileUploader = {
  instances: [],
  initialize: function($fileuploads) {
    var that = this;
    $fileuploads.each(function() {
      var $fileupload = $(this);

      that.instances.push( $fileupload );

      $fileupload.fileupload({
        autoUpload: true,
        sequentialUploads: true,
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
      });
    });

    $(document).one('turbolinks:before-cache.FileUploader', function() {
      that.teardown();
    });
  },
  teardown: function() {
    for ( var i = this.instances.length - 1; i >= 0; i-- ) {
      this.instances[i].fileupload('destroy');
    }
    this.instances = [];
  }
};

App.pageLoad.push(function() {
  App.FileUploader.initialize( $('#fileupload') );
});
