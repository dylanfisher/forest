// Set the default theme for all select2 widgets
$.fn.select2.defaults.set('theme', 'bootstrap');

App.teardown.push(function() {
  $('select').each(function() {
    var $select = $(this);
    var $sortableList = $select.closest('.form-group.select').find('.is-ui-sortable');

    if ( $sortableList.length ) {
      $sortableList.sortable('destroy');
    }

    if ( $select.data('select2') ) {
      $select.select2('destroy');
    }
  });
});

App.Select2 = {
  initialize: function($elements) {
    var that = this;

    this.add($elements);
  },
  sortable: function($select2) {
    var ul = $select2.next('.select2-container').first('ul.select2-selection__rendered');

    ul.addClass('is-ui-sortable');

    ul.sortable({
      placeholder: 'ui-state-highlight',
      forcePlaceholderSize: true,
      items: 'li:not(.select2-search)',
      stop: function() {
        $( $(ul).find('.select2-selection__choice').get().reverse() ).each(function() {
          var id = $(this).data('data').id;
          var option = $select2.find('option[value="' + id + '"]')[0];

          $select2.prepend(option);
        });
      }
    });
  },
  add: function($elements) {
    var that = this;

    $elements.each(function() {
      var $select = $(this);
      var selectOptions = {};
      var remotePath = $select.attr('data-remote-path');
      var allowClear = $select.find('option:first:empty').length;
      var placeholder = $select.attr('placeholder') || '';

      if ( remotePath && remotePath.length ) {
        selectOptions = {
          placeholder: placeholder,
          allowClear: allowClear,
          ajax: {
            url: remotePath,
            dataType: 'json',
            delay: 150,
            data: function (params) {
              var returnObj = {};
              var remoteScope = $select.attr('data-remote-scope'); // TODO: remote scope default?

              // TODO: support multiple scopes

              returnObj[remoteScope] = params.term; // search term
              returnObj['page'] = params.page;

              return returnObj;
            },
            processResults: function (response, params) {
              params.page = params.page || 1;
              return {
                results: response.data,
                pagination: {
                  more: (params.page * response.per_page) < response.total_count
                }
              };
            },
            cache: true,
          },
        };
      }

      $select.select2( selectOptions );

      if ( $select.attr('data-sortable') == 'true' ) {
        App.Select2.sortable( $select );
      }
    });
  }
};

App.pageLoad.push(function() {
  App.Select2.initialize( $('select:visible') );
});

$(document).on('app:show-media-item-chooser', function() {
  App.Select2.initialize( $('select:visible') );
});

$(document).on('app:block-slot-after-insert', function(e, blockSlot) {
  App.Select2.initialize( $(blockSlot).find('select:visible') );
});

$(document).on('app:add-menu-item', function(e, $menuItem) {
  App.Select2.add( $menuItem.find('select:visible') );
});
