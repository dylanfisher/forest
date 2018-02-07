// Analytics

$(document).on('turbolinks:load', function(e) {
  // Register Google Analytics pageview
  if ( typeof gtag === 'function' && window.GOOGLE_ANALYTICS_ID ) {
    var pagePath;

    if ( e.originalEvent && e.originalEvent.data && e.originalEvent.data.url ) {
      pagePath = e.originalEvent.data.url;
    } else {
      pagePath = window.location.href
    }

    gtag('config', window.GOOGLE_ANALYTICS_ID, { 'page_path': pagePath });
  }
});
