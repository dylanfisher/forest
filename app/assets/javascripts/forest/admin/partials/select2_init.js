// Set the default theme for all select2 widgets
$.fn.select2.defaults.set('theme', 'bootstrap');

App.Select2 = {
  instances: [],
  initialize: function($elements) {
    var that = this;

    $(document).one('turbolinks:before-cache.select2', function() {
      that.teardown();
    });

    this.add($elements);
  },
  add: function($elements) {
    var that = this;

    $elements.each(function() {
      var $select = $(this);
      var selectOptions = {};
      var remotePath = $select.attr('data-remote-path');
      var allowClear = $select.find('option:first:empty').length;
      var placeholder = $select.attr('placeholder') || '';

      that.instances.push( $select );

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
    });
  },
  teardown: function() {
    for ( var i = this.instances.length - 1; i >= 0; i-- ) {
      $(this.instances[i]).select2('destroy');
    }
    this.instances = [];
  }
};

App.pageLoad.push(function() {
  App.Select2.initialize( $('select:visible') );
});

$(document).on('app:show-media-item-chooser', function() {
  App.Select2.initialize( $('select:visible') );
});

$(document).on('app:add-menu-item', function(e, $menuItem) {
  App.Select2.add( $menuItem.find('select:visible') );
});
