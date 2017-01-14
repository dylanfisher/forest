$(document).on('click', '[data-block-collapse-all]', function() {
  var $button = $(this);
  var $wrapper = $button.closest('.panel');
  var $icon = $button.find('.glyphicon');
  var $blockWrappers = $wrapper.find('.nested-fields');
  var $blockIcons = $wrapper.find('.glyphicon');

  if ( $button.hasClass('collapsed') ) {
    $button.removeClass('collapsed');
    $blockWrappers.removeClass('collapsed');
    $icon.add($blockIcons).removeClass('glyphicon-plus').addClass('glyphicon-minus');
  } else {
    $button.addClass('collapsed');
    $blockWrappers.addClass('collapsed');
    $icon.add($blockIcons).removeClass('glyphicon-minus').addClass('glyphicon-plus');
  }
});

$(document).on('click', '[data-block-collapser]', function() {
  var $button = $(this);
  var $wrapper = $button.closest('.nested-fields');
  var $icon = $button.find('.glyphicon');
  var $body = $wrapper.find('.panel-body');

  if ( $wrapper.hasClass('collapsed') ) {
    $wrapper.removeClass('collapsed');
    $icon.removeClass('glyphicon-plus').addClass('glyphicon-minus');
  } else {
    $wrapper.addClass('collapsed');
    $icon.removeClass('glyphicon-minus').addClass('glyphicon-plus');
  }
});

$(document).on('click', '[data-collapse-parent] [data-collapse-trigger]', function() {
  var $button = $(this);
  var $wrapper = $button.closest('[data-collapse-parent]');
  var $icon = $button.find('.glyphicon');
  var $body = $wrapper.find('[data-collapse-body]');

  if ( $wrapper.hasClass('collapsed') ) {
    $wrapper.removeClass('collapsed');
    $body.show();
    $icon.removeClass('glyphicon-plus').addClass('glyphicon-minus');
  } else {
    $wrapper.addClass('collapsed');
    $body.hide();
    $icon.removeClass('glyphicon-minus').addClass('glyphicon-plus');
  }
});
