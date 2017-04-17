// Turboforms

// http://stackoverflow.com/a/20383069
$(document).on('submit', 'form[data-turboform]', function(e) {
  var $form = $(this);
  var $submit = $form.find('input[type="submit"]');

  Turbolinks.visit(this.action + ( this.action.indexOf('?') == -1 ? '?' : '&' ) + $(this).serialize() );

  $(document).one('turbolinks:before-cache.turboforms', function() {
    $submit.prop('disabled', false);
  });

  return false;
});
