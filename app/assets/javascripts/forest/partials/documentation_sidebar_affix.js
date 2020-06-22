// Documentation sidebar affix

$(document).on('turbolinks:load', function() {
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

  $(document).one('turbolinks:before-cache', function() {
    $documentationWrapper = null;
    $sidebar = null;
  });
});
