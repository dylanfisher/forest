// $(document).on('click', '[data-block-collapse-all]', function() {
//   var $button = $(this);
//   var $wrapper = $button.closest('.panel');
//   var $icon = $button.find('.collapsable-icon');
//   var $blockWrappers = $wrapper.find('.nested-fields');
//   var $blockIcons = $wrapper.find('.collapsable-icon');

//   if ( $button.hasClass('collapsed') ) {
//     $button.removeClass('collapsed');
//     $blockWrappers.removeClass('collapsed');
//     $icon.add($blockIcons).removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up');
//   } else {
//     $button.addClass('collapsed');
//     $blockWrappers.addClass('collapsed');
//     $icon.add($blockIcons).removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
//   }
// });

// $(document).on('click', '[data-block-collapser]', function() {
//   var $button = $(this);
//   var $wrapper = $button.closest('.nested-fields');
//   var $icon = $button.find('.collapsable-icon');
//   var $body = $wrapper.find('.panel-body');

//   if ( $wrapper.hasClass('collapsed') ) {
//     $wrapper.removeClass('collapsed');
//     $icon.removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up');
//   } else {
//     $wrapper.addClass('collapsed');
//     $icon.removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
//   }
// });

$(document).on('click', '[data-collapse-trigger]', function() {
  var $button = $(this);
  var $wrapper = $button.closest('[data-collapse-parent]');

  if ( !$wrapper.length ) {
    console.warn('Could not find [data-collapse-parent] for this trigger', $wrapper);
    return;
  }

  var $icon = $button.find('.collapsable-icon');
  var $body = $wrapper.find('[data-collapse-body]');

  if ( $wrapper.hasClass('collapsed') ) {
    $wrapper.removeClass('collapsed');
    $body.show();
    $icon.removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up');

    $(document).trigger('app:show-collapsed-content', $wrapper);
  } else {
    $wrapper.addClass('collapsed');
    $body.hide();
    $icon.removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
  }
});

$(document).on('click', '[data-collapse-parent] .card-header', function(e) {
  var $target = $(e.target);

  if ( $target.closest('[data-collapse-trigger]').length ) return;

  var $parent = $(this).closest('[data-collapse-parent]');
  var $trigger = $parent.find('[data-collapse-trigger]').first();

  if ( $trigger.length ) $trigger.trigger('click');
});
