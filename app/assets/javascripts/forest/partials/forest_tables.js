// Forest tables

App.pageLoad.push(function() {
  var $tables = $('[data-sortable-table]');

  if ( !$tables.length ) return;

  // Unfortunately we need to explicitly set the td widths so that the table row doesn't collapse in a
  // weird way when you begin to drag it.
  // *There may still be a bug when only a single row is listed in the table.
  var setTdWidths = function() {
    $tables.each(function() {
      var $table = $(this);
      var $rows = $table.find('[data-sortable-row]');

      $rows.each(function() {
        var $row = $(this);
        var $tds = $row.find('td');

        $tds.each(function() {
          var $td = $(this);
          var width = $td.width();

          $td.width(width);
        });
      });
    });
  };

  var updatePositionValues = function($table, ui) {
    var $rows = $table.find('[data-sortable-row]');
    var recordOffset = parseInt($table.attr('data-table-record-offset'));

    if ( isNaN(recordOffset) ) {
      console.warn('Could not parse position offset', $table, recordOffset);
      return;
    }

    var updateTablePath = $table.attr('data-update-table-position-path');
    var resource = $table.attr('data-resource');
    var recordIdsAndPositions = {};

    $rows.each(function(index) {
      var $row = $(this);
      var $input = $row.find('[name="forest_sortable_field_position"]');
      var recordId = $row.attr('data-record-id');
      var rowIndex = index + recordOffset;

      recordIdsAndPositions[recordId] = rowIndex;

      $input.val(index);
    });

    $.ajax({
      method: 'POST',
      url: updateTablePath,
      dataType: 'json',
      data: {
        resource: resource,
        records: recordIdsAndPositions
      }
    })
    .done(function(data) {
      data.forEach(function(newRecordIdAndPosition) {
        var $row = $rows.filter('[data-record-id="' + newRecordIdAndPosition.id + '"]');
        var $input = $row.find('[name="forest_sortable_field_position"]');
        var $label = $row.find('.table-position-label');

        $input.val(newRecordIdAndPosition.position);
        $label.html(newRecordIdAndPosition.position);
      });
    })
    .fail(function(data) {
      console.warn('Failed to update positions', data);
      // alert('Failed to update positions');
    });
  };

  App.pageResize.push($.debounce(250, function() {
    setTdWidths();
  }));

  setTdWidths();

  $tables.each(function() {
    var $table = $(this);

    $table.sortable({
      items: '[data-sortable-row]',
      handle: '.table-position-field',
      axis: 'y',
      helper: 'clone',
      forcePlaceholderSize: true,
      start: function(e, ui) {
        $(ui.item).appendTo($table);
        ui.placeholder.height( ui.item.outerHeight() );
      },
      stop: function(e, ui) {
        updatePositionValues($table, ui);
      }
    });
  });
});

$(document).on('mouseenter', '.forest-table tbody tr', function() {
  var $row = $(this);

  $row.addClass('active');
});

$(document).on('mouseleave', '.forest-table tbody tr', function() {
  var $row = $(this);

  $row.removeClass('active');
});

$(document).on('click', '.forest-table tbody tr', function(e) {
  var $row = $(this);

  if ( !$(e.target).closest('a, input, .table-position-field').length ) {
    var $button = $row.find('a.forest-table__link:first');

    if ( !$button.length ) {
      $button = $row.find('a.btn:first');
    }

    var url = $button.attr('href');

    if ( url ) {
      if ( e.metaKey || e.ctrlKey ) {
        window.open( url, '_blank' );
      } else if ( e.shiftKey ) {
        window.open( url, '_blank' );
        window.focus();
      } else {
        window.location = url;
      }
    }
  }
});
