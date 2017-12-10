// Analytics

$(document).on('turbolinks:load', function(e) {
  // Register Google Analytics pageview
  if ( typeof gtag === 'function' ) {
    gtag('config', App.analytics.id, { 'page_path': e.originalEvent.data.url });
  }
});
