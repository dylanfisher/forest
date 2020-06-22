App.blockKindSelector = {};

App.blockKindSelector.select2 = function($select) {
  var selectOptions = {
    placeholder: 'Select a block',
    dropdownCssClass: 'block-kind-selector',
    escapeMarkup: function (markup) {
      return markup;
    },
    templateResult: function(data) {
      var result;

      if ( $(data.element).is('optgroup') ) {
        result = data.text;
      } else {
        result = $(data.element).attr('data-select2-response');
      }

      return result;
    }
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

        $blockSlot.find('.block-slot__inputs').filter(':input:visible').not(':disabled').first().focus();

        $(document).trigger('forest:block-slot-after-insert', $blockSlot);
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
