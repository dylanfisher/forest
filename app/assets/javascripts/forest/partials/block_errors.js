// Block errors

App.pageLoad.push(function() {
  var $blocksWithErrors = $('.form-group.has-error');

  $blocksWithErrors.each(function() {
    var $blockSlot = $(this).closest('.block-slot');

    $blockSlot.addClass('block-slot--has-error');
  });
});
