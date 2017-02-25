// TODO: Implement teardown method for turbolinks:before-cache
App.pageLoad.push(function() {
  var $nestable = $('.dd');

  $nestable.nestable();

  App.getSerializedJSON = function() {
    var $items = $nestable.find('.dd-item');

    $items.each(function() {
      var $item = $(this);
      var $inputs = $item.find('.dd-input__input');

      $inputs.each(function() {
        var $thisInput = $(this);
        var inputName = $thisInput.attr('name');
        var inputValue = $thisInput.val();

        $thisInput.closest('.dd-item').data(inputName, inputValue);
      });
    });

    return window.JSON.stringify( $nestable.nestable( 'serialize' ) );
  }

  $('#menu_structure').val( App.getSerializedJSON() );

  $nestable.on('change', function() {
    if ( $(this).closest('#dd-primary').length ) {
      var $selects = $nestable.find('select');

      $selects.each(function() {
        var $select = $(this);

        var $parent = $select.closest('.dd-input');
        var $hiddenInput = $parent.find('.dd-input__input-for-select');
        var value = $select.find(':selected').val();

        $hiddenInput.val(value);
      });

      $('#menu_structure').val( App.getSerializedJSON() );
    }
  });
});

$(document).on('click', '#menu__add-item-button', function() {
  var $menu = $('#dd-primary');

  if ( $menu.find('.dd-empty').length ) {
    $menu.html('<ol class="dd-list"></ol>');
  }

  var $ddList = $menu.find('.dd-list:first');
  var itemId = $menu.find('.dd-item').length + 1;
  var $template = $('#dd-item-template');

  $template.find('.dd-item').attr('data-id', itemId);
  $template.find('.dd-handle').html('Item ' + itemId);

  $ddList.append( $template.html() );

  var $ddItem = $ddList.find('.dd-item[data-id="' + itemId + '"]');

  $(document).trigger('app:add-menu-item', [$ddItem]);
});
