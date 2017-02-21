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

      that.instances.push( $select );

      // if ( remotePath.length ) {
      //   selectOptions = {
      //     ajax: {
      //       url: remotePath,
      //       dataType: 'json',
      //       delay: 250,
      //       data: function (params) {
      //         return {
      //           q: params.term, // search term
      //           page: params.page
      //         };
      //       },
      //     },
      //     minimumInputLength: 1,
      //   };
      // }

      $select.select2( selectOptions );

      // TODO: ajax select2
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
