// Sortable fields

$(document).on('turbolinks:load app:block-slot-after-insert', function() {
  var $fieldSets = $('.sortable-field-set');

  $fieldSets.each(function() {
    var $fieldSet = $(this);

    $fieldSet.sortable({
      items: '.sortable-field',
      containment: $fieldSet,
      // tolerance: 'pointer',
      placeholder: 'sortable-placeholder',
      handle: '.sortable-field-set__handle',
      forcePlaceholderSize: true
    });

    $fieldSet.on('sortupdate.sortableFieldSets', function() {
      calculatePositions( $fieldSet );
    });

    function calculatePositions($fieldSet) {
      var $fields = $fieldSet.find('.sortable-field');

      $fields.each(function(index) {
        var $field = $(this);
        console.log(index, $field);
        var $input = $field.find('.sortable-field-set__position');

        $input.val(index);
      });
    }

    $(document).one('turbolinks:before-cache', function() {
      $fieldSet.off('sortupdate.sortableFieldSets');
      $fieldSet.sortable('destroy');
    });
  });
});
