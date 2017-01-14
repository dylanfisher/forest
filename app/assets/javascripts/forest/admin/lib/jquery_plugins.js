(function($) {

  // Remove event handlers before assigning them. This ensures that the event
  // will not stack when using turbolinks. Use a namespaced handler to
  // avoid removing all events assigned to the element.
  // http://api.jquery.com/off/
  $.fn.offOn = function(event, selector, callback) {
    if(event.indexOf('.') == -1){
      console.warn('You are disabling all "'+ event +'" events attached to "' + this.selector + '".\nConsider namespacing your event, e.g. $("element").on("click.myNamespace", function(){});');
    }
    return this.off(event).on(event, selector, callback);
  };

  // jQuery nextWrap and prevWrap selectors.
  // Usage: $('.element').nextWrap()
  $.fn.nextWrap = function( selector ) {
    var $next = $(this).next( selector );
    if ( ! $next.length ) {
      $next = $(this).parent().children( selector ).first();
    }
    return $next;
  };

  $.fn.prevWrap = function( selector ) {
    var $previous = $(this).prev( selector );
    if ( ! $previous.length ) {
      $previous = $(this).parent().children( selector ).last();
    }
    return $previous;
  };

}(jQuery));
