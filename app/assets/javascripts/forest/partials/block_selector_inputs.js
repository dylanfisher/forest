// Block selector inputs

(function() {
  var titleize = function(str) {
    // Replace dashes with spaces
    str = str.replace(/-/g, ' ');
    // Capitalize the first letter of each word
    str = str.replace(/\w\S*/g, function(txt) {
      return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
    });
    return str;
  };

  var init = function(blockSlot) {
    var $blockSelectors;

    if ( blockSlot ) {
      $blockSelectors = $(blockSlot).find('.form-group.block_selector');
    } else {
      $blockSelectors = $('.form-group.block_selector');
    }

    if ( !$blockSelectors.length ) return;

    var $blocks = $('.block-slot');

    $blocks = $blocks.filter(function() {
      var $block = $(this);

      return $block.attr('id') && $block.attr('data-kind') != 'JumpLinkBlock';
    });

    $blockSelectors.each(function() {
      var $blockSelector = $(this);
      var $select = $blockSelector.find('select.block_selector');
      var selectedValue = $select.attr('data-selected');
      var optionArray = [];

      $blocks.each(function() {
        var $block = $(this);
        var blockID = $block.attr('id');
        var blockName = titleize( blockID );
        var option = new Option(blockName, blockID, false, false);

        optionArray.push(option);
      });

      // Remove empty options from select
      $select.find('option').filter(function() {
        return !this.value || $.trim(this.value).length == 0 || $.trim(this.text).length == 0;
      }).remove();

      for ( var i = 0; i < optionArray.length; i++ ) {
        $select.append( optionArray[i] ).trigger('change');
      }

      if ( selectedValue ) {
        $select.val( selectedValue );
        $select.trigger('change');
      }
    });
  };

  App.pageLoad.push(function() {
    init();
  });

  $(document).on('forest:block-slot-after-insert', function(e, blockSlot) {
    init(blockSlot);
  });
})();
