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

    $blockSlots.offOn('cocoon:after-insert.blockDropdownSelect', function(e, $blockSlot) {
      var $blockKindSelect = $blockSlot.find('.block-kind-select');
      var $blockTemplates = $blockSlot.find('.block-slot-field-template');
      var previousBlockKindId;

      App.blockKindSelector.select2( $blockKindSelect );

      $blockKindSelect.select2('open');

      // If a block kind hasn't been chosen, remove the block slot
      $blockKindSelect.offOn('select2:close.blockDropdownSelect', function(e) {
        if ( $blockKindSelect.val() ) {
          $blockKindSelect.select2('destroy')
                          .closest('.form-group')
                          .hide();
        } else {
          $blockSlot.remove();
        }
      });

      $blockKindSelect.offOn('select2:select.blockDropdownSelect', function(e) {
        var blockKindId = $blockKindSelect.val();
        var $activeBlockTemplate = $blockSlot.find('.block-slot-field-template[data-block-kind-id="' + blockKindId + '"]');

        $blockSlot.data('hasSelectedSlot', true);

        if ( previousBlockKindId != blockKindId ) {
          disableBlockFieldTemplate( $blockTemplates.not( $activeBlockTemplate ) );
          enableBlockFieldTemplate( $activeBlockTemplate );
        }

        previousBlockKindId = blockKindId;

        $(document).trigger('app:block-slot-after-insert', $blockLayout);
      });
    });
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
