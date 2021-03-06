(function() {
  var init = function() {
    var $blockSlotWrapper = $('.block_slots');
    var $blockSlots = $('.block_slots > .nested-fields');

    updateBlockSlotPosition();

    $blockSlots.sortable({
      items: $blockSlots,
      handle: '.sortable-handle:not(button), .sortable-handle:not(a)',
      placeholder: 'ui-state-highlight',
      forcePlaceholderSize: true,
      start: function(e, ui) {
        ui.placeholder.height( ui.item.outerHeight() - 4 );
      }
    });

    $blockSlots.offOn('sortupdate.blockSlotSort', function(e, ui) {
      updateBlockSlotPosition();
    });

    function updateBlockSlotPosition() {
      var $blockLayouts = $('.block-layout');

      $blockLayouts.each(function() {
        var $layout = $(this);

        $layout.find('.block_slots > .nested-fields').each(function(index) {
          var $blockSlot = $(this);
          var $positionInput = $blockSlot.find('.block-position');

          $positionInput.val(index);
        });
      });
    }
  };

  App.pageLoad.push(function() {
    init();
  });

  $(document).on('forest:block-slot-after-insert', function() {
    init();
  });
})();
