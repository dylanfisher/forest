// Documentation sidebar affix

App.pageLoad.push(function() {
  var $documentationWrapper = $('#documentation-wrapper');

  if ( !$documentationWrapper.length ) return;

  var $sidebar = $('#documentation-sidebar');

  $sidebar.affix({
    offset: {
      top: function() {
        return $documentationWrapper.offset().top - 15;
      }
    }
  });
});
