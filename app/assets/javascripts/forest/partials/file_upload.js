// File upload
// https://github.com/shrinerb/shrine/wiki/Adding-Direct-S3-Uploads#aws-s3-setup

(function() {
  var multiFileUploadUppy;

  var disableForm = function($form) {
    var $inputs = $form.find('input[type="submit"]');

    $inputs.prop('disabled', true);
  };

  var enableForm = function($form) {
    var $inputs = $form.find('input[type="submit"]');

    $inputs.prop('disabled', false);
  };

  var generateFileData = function(file, response) {
    return JSON.stringify({
             id: response.uploadURL.match(/\/cache\/([^\?]+)/)[1], // extract key without prefix
             storage: 'cache',
             metadata: {
               size:      file.size,
               filename:  file.name,
               mime_type: file.type,
             }
           });
  };

  var generateFileDataForAjaxPost = function(file, response) {
    return {
             attachment: generateFileData(file, response)
           };
  };

  var createMediaItemFromUploadedFileData = function($fileUpload, uploadedFileData, uppy) {
    var url = $fileUpload.attr('data-media-item-url');
    var $mediaLibary = $('#media-library-infinite-load');

    $.ajax({
      method: 'POST',
      url: url,
      dataType: 'json',
      data: {
        media_item: uploadedFileData
      }
    })
    .done(function(data) {
      $mediaLibary.prepend(data['attachmentPartial']);
    })
    .fail(function(data) {
      console.warn('Media item failed to create', data);
      uppy.info( ('Error uploading file: ' + data), 'error' );
    });
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
      var uploadedFileData = generateFileData(file, response);

      uppy.info('File uploaded. Press the Update Media item button to save the record.', 'success', 600000);

      // set hidden field value to the uploaded file data so that it's submitted
      // with the form as the attachment
      hiddenInput.value = uploadedFileData;

      enableForm($form);
    });
  };

  var initializeUppyDashboardModal = function(uppy, $fileUpload) {
    uppy.reset();

    $(document).on('dragenter.uppyDashboardModal', function(e) {
      $(document).off('dragenter.uppyDashboardModal');
      uppy.getPlugin('Dashboard').openModal();
      e.preventDefault();
    });
  };

  var multiFileUpload = function($fileUpload) {
    var uppy = Uppy.Core({
        autoProceed: true
      })
      .use(Uppy.Dashboard, {
        inline: false,
        proudlyDisplayPoweredByUppy: false,
        // closeModalOnClickOutside: true,
        showLinkToFileUploadResult: false,
        closeAfterFinish: true
        // height: 300,
        // width: '100%',
        // hideProgressAfterFinish: true
      })
      .use(Uppy.ThumbnailGenerator, {
        thumbnailWidth: 600,
      })
      uppy.use(Uppy.AwsS3Multipart, {
        companionUrl: '/',
      });

    multiFileUploadUppy = uppy;

    initializeUppyDashboardModal(uppy, $fileUpload);

    uppy.on('dashboard:modal-closed', function() {
      initializeUppyDashboardModal(uppy, $fileUpload);
    });

    uppy.on('upload-success', function(file, response) {
      // construct uploaded file data in the format that Shrine expects
      var uploadedFileData = generateFileDataForAjaxPost(file, response);

      createMediaItemFromUploadedFileData($fileUpload, uploadedFileData, uppy);
    });
  };

  var initializeMultiFileUpload = function($multiFileUpload) {
    if ( $multiFileUpload.length ) {
      multiFileUpload( $multiFileUpload );
    }
  };

  var destroyMultiFileUpload = function($multiFileUpload) {
    if ( multiFileUploadUppy ) multiFileUploadUppy.close();
    $(document).off('dragenter.uppyDashboardModal');
  };

  App.pageLoad.push(function() {
    $('.file-upload').each(function() {
      singleFileUpload( $(this) );
    });

    initializeMultiFileUpload( $('.multi-file-upload').filter(':visible') );
  });

  $(document).on('show.bs.modal', function(e) {
    var $modal = $(e.target);

    if ( $modal.attr('id') == 'media-item-chooser' ) {
      initializeMultiFileUpload( $('#media-item-chooser .multi-file-upload') );
    }
  });

  $(document).on('hide.bs.modal', function(e) {
    var $modal = $(e.target);

    if ( $modal.attr('id') == 'media-item-chooser' ) {
      destroyMultiFileUpload( $('#media-item-chooser .multi-file-upload') );
    }
  });
})();
