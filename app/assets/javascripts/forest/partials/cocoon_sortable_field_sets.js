// Sortable fields
//
// This pattern for sorting fields can be used with the Cocoon gem.
//
// Sortable field sets can be nested multiple times, but need to follow this hierarchy:
// <div class="sortable-field-set">
//   <div class="sortable-field">
//     <div class="sortable-field-set__handle"></div>
//     <div class="sortable-field-set__position">
//       <%= f.hidden_field :position %>
//     </div>
//   </div>
// </div>

// TODO: ready function
$(document).on('turbolinks:load cocoon:after-insert', function() {
  var $fieldSets = $('.sortable-field-set');

  $fieldSets.each(function() {
    var $fieldSet = $(this);

    $fieldSet.sortable({
      items: '> .sortable-field',
      containment: $fieldSet,
      // tolerance: 'pointer',
      placeholder: 'sortable-placeholder',
      handle: '.sortable-field-set__handle',
      forcePlaceholderSize: true,
      start: function(e, ui) {
        ui.placeholder.height( ui.item.outerHeight(true) );
      }
    });

    calculatePositions( $fieldSet );

    $fieldSet.on('sortupdate.sortableFieldSets', function() {
      calculatePositions( $fieldSet );
    });
  });

  function calculatePositions($fieldSet) {
    var $fields = $fieldSet.find('> .sortable-field');

    $fields.each(function(index) {
      var $field = $(this);
      var $input = $field.find('> .sortable-field-set__position input');

      $input.val(index);
    });
  }
});
