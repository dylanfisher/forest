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

  // https://gist.github.com/zergius-eggstream/bea51020b471886bafe1b2baef9817b8
  // usage: $('.container').shiftSelectable() to select all checkboxes in container $('.cont')
  // or $('.container').shiftSelectable({items: '.shift-selectable'}) to select only checkboxes with shift-selectable class
  $.fn.shiftSelectable = function(config) {
    config = $.extend({
      items: 'input[type="checkbox"]',
      trigger: 'change',
      triggerOnSelf: true
    }, config);
    var $container = this;
    var lastChecked;

    $container.on('click', config.items, function(evt) {
      if ( !lastChecked ) {
        lastChecked = this;
        return;
      }

      var $items = $container.find(config.items);

      if ( evt.shiftKey ) {
        var start = $items.index(this);
        var end = $items.index(lastChecked);
        var $triggeredItems = $items.slice(Math.min(start, end), Math.max(start, end) + 1);

        if ( !config.triggerOnSelf ) {
          $triggeredItems = $triggeredItems.not( $(this) );
          $(lastChecked)
            .attr('checked', lastChecked.checked)
            .trigger(config.trigger);
        }

        $triggeredItems
          .attr('checked', lastChecked.checked)
          .trigger(config.trigger);
      }

      lastChecked = this;
    });
  };

}(jQuery));
