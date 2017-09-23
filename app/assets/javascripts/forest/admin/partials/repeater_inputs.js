// Repeater inputs

$(document).on('click', '.repeater__add-item-button', function() {
  var $repeater = $(this).closest('.form-group.repeater');
  var $template = $repeater.find('.repeater__template').attr('data-template');
  var $itemWrapper = $repeater.find('.repeater__group-wrapper');

  $itemWrapper.append( $template );
});

$(document).on('click', '.repeater__controls__add-row-button', function() {
  var $repeater = $(this).closest('.form-group.repeater');
  var $group = $(this).closest('.repeater__group');
  var $template = $repeater.find('.repeater__template').attr('data-template');

  $group.before( $template );
});

$(document).on('click', '.repeater__controls__remove-row-button', function() {
  var $group = $(this).closest('.repeater__group');

  $group.remove();
});

