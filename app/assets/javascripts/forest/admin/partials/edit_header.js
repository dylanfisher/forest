$(document).on('click', '.update-record-button', function() {
  var $form = $('form[class*="edit_"]:first');
  var $submitButton = $form.find('input[type="submit"]:first');

  $submitButton.trigger('click');
});
