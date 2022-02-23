// Timepicker init

(function() {
  var inputSelector = '.form-group.timepicker input.timepicker';
  var initTimepicker = function($inputs) {
    $inputs.each(function() {
      var $input = $(this);
      var options = {};

      $input.timepicker(options);
    });
  };

  App.pageLoad.push(function() {
    var $inputs = $(inputSelector).filter(':visible');

    initTimepicker($inputs);
  });

  $(document).on('shown.bs.tab', function(e) {
    var $tabContent = $( $(e.target).attr('href') );

    if ( !$tabContent.length ) return;

    initTimepicker( $tabContent.find(inputSelector).filter(':visible') );
  });

  $(document).on('forest:block-slot-after-insert', function(event, nestedFields) {
    initTimepicker( $(nestedFields).find(inputSelector).filter(':visible') );
  });
})();
