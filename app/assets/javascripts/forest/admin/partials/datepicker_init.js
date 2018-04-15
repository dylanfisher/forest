App.Datepicker = {
  instances: [],
  initialize: function($elements) {
    var that = this;

    $(document).one('turbolinks:before-cache.Datepicker', function() {
      that.teardown();
    });

    this.add( $elements );
  },
  add: function($elements) {
    var that = this;

    $elements.each(function() {
      var $el = $(this);
      var options = {
        dateFormat: 'yy-mm-dd'
      };

      if ( $el.data('datepicker') ) {
        // Already initialized
      } else {
        that.instances.push( $el );
      }

      $el.datepicker( options );
    });
  },
  teardown: function() {
    for ( var i = this.instances.length - 1; i >= 0; i-- ) {
      $(this.instances[i]).datepicker('destroy');
    }
    this.instances = [];
  }
};

App.pageLoad.push(function() {
  App.Datepicker.initialize( $('.form-group[class*="_scheduled_date"] input[name$="[scheduled_date]"]:visible') );
  App.Datepicker.initialize( $('.form-group [data-datepicker="true"]:visible') );
});
