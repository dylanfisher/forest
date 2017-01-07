App.pageLoad.push(function() {
  var $nestable = $('.dd');
  var $input = $('#menu_structure');
  var initialStructure = $input.val();

  $nestable.nestable({
    group: 1
  });

  $input.val( getSerializedJSON() );

  $nestable.on('change', function() {
    if ( $(this).closest('#dd-primary').length ) {
      $input.val( getSerializedJSON() );
    }
  });

  function getSerializedJSON() {
    var serialized = $nestable.nestable( 'serialize' );
    return window.JSON.stringify( serialized );
  }
});

$(document).on('click', '#menu__add-item-button', function() {
  var $placeholder = $('#menu__new-item-placeholder');
  if ( $placeholder.find('.dd-empty').length ) {
    $placeholder.html('<ol class="dd-list"></ol>');
  }
  var $ddList = $placeholder.find('.dd-list:first');
  var itemId = $('.dd-item').length + 1;
  var itemHtml = '<li class="dd-item" data-id="' + itemId + '"><div class="dd-handle">Item ' + itemId + '</div></li>';

  $placeholder.append( itemHtml );
});

$(document).on('click', '.dd-input-expand, .dd-input-collapse', function() {
  var $wrapper = $(this).closest('.dd-item');

  if ( $wrapper.hasClass('dd-expanded') ) {
    $wrapper.removeClass('dd-expanded');
  } else {
    $wrapper.addClass('dd-expanded');
  }
});
