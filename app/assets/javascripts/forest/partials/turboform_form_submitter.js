// Turboforms

// http://stackoverflow.com/a/20383069
$(document).on('submit', 'form[data-turboform]', function(e) {
  var $form = $(this);
  var $submit = $form.find('input[type="submit"]');

  window.location = (this.action + ( this.action.indexOf('?') == -1 ? '?' : '&' ) + $(this).serialize() );

  return false;
});
