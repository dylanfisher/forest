App.blockKindSelector = {};

App.blockKindSelector.select2 = function($select) {
  var selectOptions = {
    placeholder: 'Select a block'
  }

  $select.select2( selectOptions );
};

App.pageLoad.push(function() {
  var $blockLayouts = $('.block-layout');

  $blockLayouts.each(function() {
    var $blockLayout = $(this);
    var $blockSlots = $blockLayout.find('.block_slots');
    var $emptyLayoutDescription = $blockLayout.find('.block-layout__empty-description');

    $blockSlots.offOn('cocoon:after-insert.blockDropdownAfterInsert', function(e, $blockSlot) {
      var $blockKindSelect = $blockSlot.find('.block-kind-select');
      var $blockTemplates = $blockSlot.find('.block-slot-field-template');
      var previousBlockKindId;

      App.blockKindSelector.select2( $blockKindSelect );

      $emptyLayoutDescription.hide();

      $blockKindSelect.select2('open');

      // If a block kind hasn't been chosen, remove the block slot
      $blockKindSelect.offOn('select2:close.blockDropdownSelectClose', function(e) {
        if ( $blockKindSelect.val() ) {
          $blockKindSelect.select2('destroy')
                          .closest('.form-group')
                          .hide();
        } else {
          $blockSlot.remove();
          $emptyLayoutDescription.show();
        }
      });

      $blockKindSelect.offOn('select2:select.blockDropdownSelect', function(e) {
        var blockKindId = $blockKindSelect.val();
        var $activeBlockTemplate = $blockSlot.find('.block-slot-field-template[data-block-kind-id="' + blockKindId + '"]');

        if ( previousBlockKindId != blockKindId ) {
          disableBlockFieldTemplate( $blockTemplates.not( $activeBlockTemplate ) );
          enableBlockFieldTemplate( $activeBlockTemplate );
        }

        previousBlockKindId = blockKindId;

        console.log($blockSlot);
        console.log($blockSlot.find('.block-slot__inputs :input:visible').not(':disabled'));
        $blockSlot.find('.block-slot__inputs :input:visible').not(':disabled').first().focus();

        $(document).trigger('app:block-slot-after-insert', $blockSlot);
      });
    });

    $blockSlots.offOn('cocoon:after-remove.blockDropdownAfterRemove', function(e, $blockSlot) {
      if ( blockCount() < 1 ) {
        $emptyLayoutDescription.show();
      }
    });

    function blockCount() {
      return $blockLayout.find('.nested-fields').length;
    }
  });

  function disableBlockFieldTemplate($templates) {
    $templates.each(function() {
      var $template = $(this);
      var $inputs = $template.find(':input');

      $inputs.attr('disabled', 'disabled');

      $template.hide();
    });
  }

  function enableBlockFieldTemplate($templates) {
    $templates.each(function() {
      var $template = $(this);
      var $inputs = $template.find(':input');

      $template.show();

      $inputs.removeAttr('disabled');
    });
  }
});