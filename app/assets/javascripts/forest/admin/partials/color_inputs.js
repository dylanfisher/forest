// Color inputs

$(document).on('change', '.form-control.color', function() {
  var $input = $(this);
  var $wrapper = $input.closest('.form-group.color');
  var $target = $wrapper.find('.color-input__hex-tracker');
  var value = $input.val();

  $target.val(value);
});

$(document).on('keyup', '.color-input__hex-tracker', function() {
  var $input = $(this);
  var $wrapper = $input.closest('.form-group.color');
  var $target = $wrapper.find('.form-control.color');
  var value = $input.val();

  if ( /(^#?[0-9A-F]{6}$)/i.test( value ) ) {
    if ( value[0] != '#' ) {
      value = '#' + value;
    }
    $target.val(value);
  }
});
