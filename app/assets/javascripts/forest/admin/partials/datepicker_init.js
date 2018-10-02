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
    var date = new Date();
    var year = date.getFullYear().toString();
    var month = (date.getMonth() + 1).toString().padStart(2, 0);
    var day = date.getDay().toString().padStart(2, 0);
    var defaultDate = year + '-' + month + '-' + day;

    $elements.each(function() {
      var $el = $(this);
      var options = {
        dateFormat: 'yy-mm-dd'
      };

      if ( $el.data('datepicker') && $el.data('datepicker')['input'] ) {
        // Already initialized
      } else {
        that.instances.push( $el );
      }

      $el.datepicker( options );

      if ( $el.hasClass('required') && $el.datepicker('getDate') == null ) {
        $el.datepicker('setDate', defaultDate);
      }
    });
  },
  teardown: function() {
    $.datepicker.dpDiv.remove();
    for ( var i = this.instances.length - 1; i >= 0; i-- ) {
      $(this.instances[i]).datepicker('destroy');
    }
    this.instances = [];
  }
};

$(document).on('turbolinks:before-render', function(e) {
  $.datepicker.dpDiv.appendTo(e.originalEvent.data.newBody);
});

App.pageLoad.push(function() {
  App.Datepicker.initialize( $('.form-group[class*="_scheduled_date"] input[name$="[scheduled_date]"]').filter(':visible') );
  App.Datepicker.initialize( $('.form-group [data-datepicker="true"]').filter(':visible') );
});
