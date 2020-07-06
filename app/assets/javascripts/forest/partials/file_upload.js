// File upload
// https://github.com/shrinerb/shrine/wiki/Adding-Direct-S3-Uploads#aws-s3-setup

(function() {
  var disableForm = function($form) {
    var $inputs = $form.find('input[type="submit"]');

    $inputs.prop('disabled', true);
  };

  var enableForm = function($form) {
    var $inputs = $form.find('input[type="submit"]');

    $inputs.prop('disabled', false);
  };

  var singleFileUpload = function($fileUpload) {
    var $form = $fileUpload.closest('form');
    var $wrapper = $fileUpload.closest('.file-upload-wrapper');
    var hiddenInput = $fileUpload.find('.file-upload__data')[0];
    var imagePreview = document.querySelector('.upload-preview img');
    var fileInput = $fileUpload.find('.file-upload__file')[0];
    var formGroup = $fileUpload[0];
    var informerParent = $wrapper.find('.file-upload-notifications');

    // remove our file input in favour of Uppy's
    formGroup.removeChild(fileInput)

    var uppy = Uppy.Core({
        autoProceed: true
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
        target: informerParent[0],
      })
      .use(Uppy.StatusBar, {
        target: $fileUpload[0]
      })
      .use(Uppy.ThumbnailGenerator, {
        thumbnailWidth: ($fileUpload.width() * 2),
      })
      uppy.use(Uppy.AwsS3Multipart, {
        companionUrl: '/',
      });

    uppy.on('thumbnail:generated', function(file, preview) {
      // show preview of the image using URL from thumbnail generator
      imagePreview.src = preview
    });

    uppy.on('upload', function(file, response) {
      disableForm($form);
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

      uppy.info('File uploaded. Press the Update Media item button to save the record.', 'success');

      // set hidden field value to the uploaded file data so that it's submitted
      // with the form as the attachment
      hiddenInput.value = JSON.stringify(uploadedFileData);

      enableForm($form);
    });
  };

  var multiFileUpload = function($fileUpload) {
    // TODO:
    // var uppy = Uppy.Core({
    //     autoProceed: true,
    //   })
    //   .use(Uppy.Dashboard, {
    //     target: $fileUpload[0],
    //     inline: true,
    //     height: 300,
    //     hideProgressAfterFinish: true
    //   })
    //   // .use(Uppy.FileInput, {
    //   //   target: formGroup,
    //   //   locale: {
    //   //     strings: {
    //   //       chooseFiles: 'Choose file'
    //   //     }
    //   //   }
    //   // })
    //   .use(Uppy.Informer, {
    //     target: formGroup,
    //   })
    //   // .use(Uppy.StatusBar, {
    //   //   target: $fileUpload[0],
    //   //   showProgressDetails: true
    //   // })
    //   .use(Uppy.ThumbnailGenerator, {
    //     thumbnailWidth: 600,
    //   })
    //   uppy.use(Uppy.AwsS3Multipart, {
    //     companionUrl: '/',
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
