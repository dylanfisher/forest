// Multi checkbox selector

App.pageLoad.push(function() {
  var $parentElements = $('.multi-checkbox-parent');

  $parentElements.each(function() {
    var $parentElement = $(this);
    var $inputs = $parentElement.find(':checkbox');
    var lastChecked = null;

    $inputs.click(function(e) {
      if ( !lastChecked ) {
        lastChecked = this;
        return;
      }

      if ( e.shiftKey ) {
        var start = $inputs.index(this);
        var end = $inputs.index(lastChecked);

        $inputs.slice(Math.min(start, end), Math.max(start, end)+ 1).prop('checked', lastChecked.checked);
      }

      lastChecked = this;
    });
  });
});
