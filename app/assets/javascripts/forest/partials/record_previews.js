// Record previews

$(document).on('click', '.preview-record-button', function(e) {
  e.preventDefault();

  var $form = $('form[class*="edit_"]:first');
  var $submitButton = $form.find('input[type="submit"]:last');
  var previewPath = $form.attr('data-preview-path');
  var defaultAction = $form.attr('action');

  $form.attr('action', previewPath)
       .attr('target', '_blank');

  $submitButton.trigger('click');

  $form.attr('action', defaultAction)
       .removeAttr('target');

  if ( $.rails ) {
    window.setTimeout(function() {
      $.rails.enableFormElements($form);
    }, 500);
  }
});
