// File upload
// https://github.com/shrinerb/shrine/wiki/Adding-Direct-S3-Uploads#aws-s3-setup

(function() {
  var singleFileUpload = function($fileUpload) {
    var hiddenInput = $fileUpload.find('.file-upload__data')[0];
    var imagePreview = document.querySelector('.upload-preview img');
    var fileInput = $fileUpload.find('.file-upload__file')[0];
    var formGroup = $fileUpload[0];

    // remove our file input in favour of Uppy's
    formGroup.removeChild(fileInput)

    var uppy = Uppy.Core({
        autoProceed: true,
      })
      .use(Uppy.FileInput, {
        target: formGroup,
        locale: {
          strings: {
            chooseFiles: 'Choose file'
          }
        }
      })
      .use(Uppy.Informer, {
        target: formGroup,
      })
      .use(Uppy.StatusBar, {
        target: $fileUpload[0],
        showProgressDetails: true
      })
      .use(Uppy.ThumbnailGenerator, {
        thumbnailWidth: 600,
      })
      uppy.use(Uppy.AwsS3Multipart, {
        companionUrl: '/',
      });

    uppy.on('thumbnail:generated', function(file, preview) {
      // show preview of the image using URL from thumbnail generator
      imagePreview.src = preview
    });

    uppy.on('upload-success', function(file, response) {
      // construct uploaded file data in the format that Shrine expects
      var uploadedFileData = JSON.stringify({
        id: response.uploadURL.match(/\/cache\/([^\?]+)/)[1], // extract key without prefix
        storage: 'cache',
        metadata: {
          size:      file.size,
          filename:  file.name,
          mime_type: file.type,
        }
      });

      // set hidden field value to the uploaded file data so that it's submitted
      // with the form as the attachment
      hiddenInput.value = JSON.stringify(uploadedFileData)
    });
  };

  var multiFileUpload = function($fileUpload) {
    // TODO:
    // var uppy = Uppy.Core()
    //   .use(Uppy.Dashboard, {
    //     // target: $fileUpload[0]
    //   });
  };

  App.pageLoad.push(function() {
    $('.file-upload').each(function() {
      singleFileUpload( $(this) );
    });

    $('.file-multi-upload').each(function() {
      multiFileUpload( $(this) );
    });
  });
})();
