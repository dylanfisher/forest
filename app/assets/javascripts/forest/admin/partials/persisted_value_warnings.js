// Persisted value warning

(function() {
  var warningMessage = '<span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span> You are changing the currently saved value for this input.';

  $(document).on('keyup', '[data-persisted-value]', function() {
    var $input = $(this);
    var persistedValue = $input.attr('data-persisted-value');
    var $wrapper = $input.closest('.form-group');

    if ( !persistedValue ) return;

    var value = $input.val();
    var $label = $wrapper.find('.control-label');

    if ( !$label.length ) return;

    var $warning = $wrapper.find('.persisted-value-warning');
    var warningMessageOverride = $input.attr('data-persisted-value-warning');

    if ( warningMessageOverride ) {
      warningMessage = warningMessageOverride;
    }

    if ( value != persistedValue ) {
      $wrapper.addClass('has-persisted-value-warning');

      if ( $warning.length ) {
        $warning.html(warningMessage);
      } else {
        $label.before('<div class="alert alert-warning persisted-value-warning" role="alert">' + warningMessage + '</div>');
      }
    } else {
      $warning.remove();
      $wrapper.removeClass('has-persisted-value-warning');
    }
  });
})();
