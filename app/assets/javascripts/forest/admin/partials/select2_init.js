App.Select2 = {
  instances: [],
  initialize: function($elements, options) {
    var that = this;
    options = options ? options : {};

    $(document).one('turbolinks:before-cache.select2', function() {
      that.teardown();
    });

    $elements.each(function() {
      var $select = $(this);
      var selectOptions = {};
      var remotePath = $select.attr('data-remote-path');
      var remoteScope = $select.attr('data-remote-scope'); // TODO: remote scope default?

      that.instances.push( $select );

      if ( remotePath && remotePath.length ) {
        selectOptions = {
          ajax: {
            url: remotePath,
            dataType: 'json',
            delay: 150,
            data: function (params) {
              return {
                [remoteScope]: params.term, // search term
                page: params.page
              };
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
