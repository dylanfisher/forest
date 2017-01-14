App.pageLoad.push(function() {
  var $dropdown = $('#block-dropdown');

  if ( !$dropdown.length ) return;

  var $dropdownItems = $dropdown.find('.block-dropdown__item');
  var $linkToAddAssociation = $('[data-association="page_slot"]');
  var blockType;
  var blockTypeId;

  $dropdownItems.offOn('click.blockDropdown', function(e) {
    var $dropdownItem = $(this);
    blockType = $dropdownItem.attr('data-block-type');
    blockTypeId = $dropdownItem.attr('data-block-type-id');

    e.preventDefault();

    $linkToAddAssociation.trigger('click');
  });

  $('#page_slots').offOn('cocoon:after-insert.blockDropdownSelect', function(e, $addedPageSlot) {
    var $select = $addedPageSlot.find('.page_page_slots_blockable_type select');
    var $option = $select.find('option[value="' + blockType + '"]');

    $option.prop('selected', true);
    $select.trigger('change');

    $('#page_slots').trigger('updatePageSlotPosition.forest');
  });
});

$(document).on('change', '#page_slots .page_page_slots_blockable_type select', function() {
  var $select = $(this);
  var blockType = $select.val();
  var $wrapper = $select.closest('.nested-fields');
  var $blockHeader = $wrapper.find('[data-block-type-header]');
  var $templateFields = $wrapper.find('.block-type-field-template');
  var $templateField = $wrapper.find('.block-type-field-template[data-block-type="' + blockType + '"]');

  $blockHeader.html(blockType);

  $templateFields.removeClass('active');
  $templateField.addClass('active');

  $(document).trigger('app:page-slot-after-insert', $wrapper);
});
