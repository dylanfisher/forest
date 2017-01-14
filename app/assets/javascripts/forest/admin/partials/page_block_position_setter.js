App.pageLoad.push(function() {
  var $pageSlotWrapper = $('#page_slots');
  var $pageSlots = $('#page_slots > .nested-fields');

  updatePageSlotPosition();

  $pageSlots.sortable({
    items: $pageSlots,
    handle: '.sortable-handle'
  });

  $pageSlots.offOn('sortupdate.pageSlotSort', function(e, ui) {
    updatePageSlotPosition();
  });

  $pageSlotWrapper.offOn('updatePageSlotPosition.forest', function() {
    updatePageSlotPosition();
  });

  function updatePageSlotPosition() {
    $('#page_slots > .nested-fields').each(function(index) {
      var $pageSlot = $(this);
      var $positionInput = $pageSlot.find('.page_page_slots_position input');

      $positionInput.val(index);
    });
  }
});
