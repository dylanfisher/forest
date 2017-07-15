App.pageLoad.push(function() {
  var $dropdown = $('#block-dropdown');

  if ( !$dropdown.length ) return;

  var $dropdownItems = $dropdown.find('.block-dropdown__item');
  var $linkToAddAssociation = $('[data-association="block_slot"]');
  var blockType;
  var blockTypeId;

  $dropdownItems.offOn('click.blockDropdown', function(e) {
    var $dropdownItem = $(this);
    blockType = $dropdownItem.attr('data-block-type');
    blockTypeId = $dropdownItem.attr('data-block-type-id');

    e.preventDefault();

    $linkToAddAssociation.trigger('click');
  });

  $('#block_slots').offOn('cocoon:after-insert.blockDropdownSelect', function(e, $addedBlockSlot) {
    var $select = $addedBlockSlot.find('.block-type-selector select');
    var $option = $select.find('option[value="' + blockType + '"]');

    $option.prop('selected', true);
    $select.trigger('change');

    $('#block_slots').trigger('updateBlockSlotPosition.forest');
  });
});

$(document).on('change', '#block_slots .block-type-selector select', function() {
  var $select = $(this);
  var blockType = $select.val();
  var $wrapper = $select.closest('.nested-fields');
  var $blockHeader = $wrapper.find('[data-block-type-header]');
  var $templateFields = $wrapper.find('.block-type-field-template');
  var $templateField = $wrapper.find('.block-type-field-template[data-block-type="' + blockType + '"]');

  $blockHeader.html(blockType);

  $templateFields.removeClass('active');
  $templateField.addClass('active');

  $wrapper.find('input:first').focus();

  $(document).trigger('app:block-slot-after-insert', $wrapper);
});
