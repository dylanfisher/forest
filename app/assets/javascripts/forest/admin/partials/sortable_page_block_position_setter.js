$(document).on('turbolinks:load app:block-slot-after-insert', function() {
  var $blockSlotWrapper = $('#block_slots');
  var $blockSlots = $('#block_slots > .nested-fields');

  updateBlockSlotPosition();

  $blockSlots.sortable({
    items: $blockSlots,
    handle: '.sortable-handle:not(button), .sortable-handle:not(a)',
    placeholder: 'ui-state-highlight',
    forcePlaceholderSize: true,
    tolerance: 'pointer',
  });

  $blockSlots.offOn('sortupdate.blockSlotSort', function(e, ui) {
    updateBlockSlotPosition();
  });

  $blockSlotWrapper.offOn('updateBlockSlotPosition.forest', function() {
    updateBlockSlotPosition();
  });

  function updateBlockSlotPosition() {
    $('#block_slots > .nested-fields').each(function(index) {
      var $blockSlot = $(this);
      var $positionInput = $blockSlot.find('.block-position input');

      $positionInput.val(index);
    });
  }
});
