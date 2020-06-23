// Repeater inputs

$(document).on('click', '.repeater__add-item-button', function() {
  var $repeater = $(this).closest('.form-group.repeater');
  var $template = $repeater.find('.repeater__template').attr('data-template');
  var $itemWrapper = $repeater.find('.repeater__group-wrapper');

  $itemWrapper.append( $template );
});

$(document).on('click', '.repeater__controls__add-row-button', function() {
  var $button = $(this);
  var $groupWrapper = $button.closest('.repeater__group-wrapper');
  var $repeater = $button.closest('.form-group.repeater');
  var $group = $button.closest('.repeater__group');
  var $template = $repeater.find('.repeater__template').attr('data-template');

  $group.before( $template );

  $groupWrapper.find('.repeater__disabled-input').prop('disabled', true);
});

$(document).on('click', '.repeater__controls__remove-row-button', function() {
  var $button = $(this);
  var $groupWrapper = $button.closest('.repeater__group-wrapper');
  var $group = $button.closest('.repeater__group');

  $group.remove();

  if ( !$groupWrapper.find('.repeater__group').length ) {
    $groupWrapper.find('.repeater__disabled-input').prop('disabled', false);
  } else {
    $groupWrapper.find('.repeater__disabled-input').prop('disabled', true);
  }
});

// TODO: ready function
$(document).on('turbolinks:load forest:block-slot-after-insert', function() {
  var $elements = $('.repeater__group-wrapper');

  $elements.each(function() {
    var $element = $(this);

    $element.sortable({
      items: '.repeater__group',
      containment: $element,
      tolerance: 'pointer'
    });
  });
});
