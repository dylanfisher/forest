// Block errors

$(document).on('turbolinks:load', function() {
  var $blocksWithErrors = $('.form-group.has-error');

  $blocksWithErrors.each(function() {
    var $blockSlot = $(this).closest('.block-slot');

    $blockSlot.addClass('block-slot--has-error');
  });
});
