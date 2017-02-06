App.pageLoad.push(function() {
  var $nestable = $('.dd');

  $nestable.nestable({
    group: 1
  });

  $('#menu_structure').val( getSerializedJSON() );

  $nestable.on('change', function() {
    if ( $(this).closest('#dd-primary').length ) {
      $('#menu_structure').val( getSerializedJSON() );
    }
  });

  function getSerializedJSON() {
    var $items = $nestable.find('.dd-item');

    $items.each(function() {
      var $item = $(this);
      var $inputs = $item.find('.dd-input__input');

      $inputs.each(function() {
        var $thisInput = $(this);
        var inputName = $thisInput.attr('name');
        var inputValue = $thisInput.val();

        $thisInput.closest('.dd-item').attr('data-' + inputName, inputValue);
      });
    });

    return window.JSON.stringify( $nestable.nestable( 'serialize' ) );
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
