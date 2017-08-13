App.pageLoad.push(function() {
  var $blockLayouts = $('.block-layout');

  $blockLayouts.each(function() {
    var $blockLayout = $('.block-layout');
    var $dropdown = $blockLayout.find('.block-dropdown');

    if ( !$dropdown.length ) return;

    var $dropdownItems = $dropdown.find('.block-dropdown__item');
    var blockKind;
    var blockKindId;

    $dropdownItems.offOn('click.blockDropdown', function(e) {
      var $dropdownItem = $(this);
      var $thisBlockLayout = $dropdownItem.closest($blockLayout);
      var $linkToAddAssociation = $thisBlockLayout.find('[data-association="block_slot"]');

      blockKind = $dropdownItem.attr('data-block-type');
      blockKindId = $dropdownItem.attr('data-block-type-id');

      e.preventDefault();

      $linkToAddAssociation.trigger('click');
    });

    $('.block_slots').offOn('cocoon:after-insert.blockDropdownSelect', function(e, $addedBlockSlot) {
      var $select = $addedBlockSlot.find('.block-type-selector select');
      var $option = $select.find('option[value="' + blockKind + '"]');

      $option.prop('selected', true);
      $select.trigger('change');

      $(this).trigger('updateBlockSlotPosition.forest');
    });
  });
});

$(document).on('change', '.block_slots .block-type-selector select', function() {
  var $select = $(this);
  var blockKind = $select.val();
  var $wrapper = $select.closest('.nested-fields');
  var $blockHeader = $wrapper.find('[data-block-type-header]');
  var $blockHeaderTitle = $blockHeader.find('.block-type-header-title');
  var $templateFields = $wrapper.find('.block-type-field-template');
  var $templateField = $wrapper.find('.block-type-field-template[data-block-type="' + blockKind + '"]');

  $blockHeaderTitle.html(blockKind);

  $templateFields.removeClass('active');
  $templateField.addClass('active');

  $wrapper.find('input:first').focus();

  $(document).trigger('app:block-slot-after-insert', $wrapper);
});
