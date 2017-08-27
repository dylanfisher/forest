$(document).on('click', '[data-block-add]', function() {
  var $blockLayout = $(this).closest('.block-layout');
  var $blockSlot = $(this).closest('.block-slot');
  var $blockSlots = $blockLayout.find('.block_slots');
  var $addBlockButton = $blockLayout.find('.add-block-button');
  var initialInsertionNode = $addBlockButton.attr('data-association-insertion-node');

  $blockSlot.attr('data-insertion-target', true);

  $addBlockButton.attr('data-association-insertion-node', '[data-insertion-target]');

  $addBlockButton.trigger('click');

  $blockSlot.removeAttr('data-insertion-target');

  if ( initialInsertionNode ) {
    $addBlockButton.attr('data-association-insertion-node', initialInsertionNode);
  } else {
    $addBlockButton.removeAttr('data-association-insertion-node')
                   .removeData('association-insertion-node');
  }
});
