App.pageLoad.push(function() {
  var $blockLayouts = $('.block-layout');

  $blockLayouts.each(function() {
    var $blockLayout = $(this);
    var $blockSlots = $blockLayout.find('.block_slots');

    $blockSlots.offOn('cocoon:after-insert.blockDropdownSelect', function(e, $blockSlot) {
      var $blockKindSelect = $blockSlot.find('.block-kind-select');
      var $blockTemplates = $blockSlot.find('.block-slot-field-template');
      var previousBlockKindId;

      App.Select2.initialize( $blockKindSelect );

      $blockKindSelect.trigger('change');

      $blockKindSelect.select2('open');

      $blockKindSelect.offOn('select2:select.blockDropdownSelect select2:close.blockDropdownSelect', function(e) {
        var blockKindId = $blockKindSelect.val();
        var $activeBlockTemplate = $blockSlot.find('.block-slot-field-template[data-block-kind-id="' + blockKindId + '"]');

        if ( previousBlockKindId != blockKindId ) {
          disableBlockFieldTemplate( $blockTemplates.not( $activeBlockTemplate ) );
          enableBlockFieldTemplate( $activeBlockTemplate );
        }

        previousBlockKindId = blockKindId;
      });

      // $(this).trigger('updateBlockSlotPosition.forest');
      // $(document).trigger('app:block-slot-after-insert', $blockLayout);
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
