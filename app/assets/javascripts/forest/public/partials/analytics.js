// Analytics

$(document).on('turbolinks:load', function(e) {
  // Register Google Analytics pageview
  if ( typeof ga === 'function' ) {
    ga('set', 'location', e.originalEvent.data.url);
    return ga('send', 'pageview');
  }
});
