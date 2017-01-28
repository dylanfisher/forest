App.InfiniteLoader = {
  instances: [],
  scrollListeners: [],
  initialize: function($elements, options) {
    var that = this;
    options = options ? options : {};
    $scrollListener = options.$scrollListener ? options.$scrollListener : $(window);
    this.scrollListeners.push($scrollListener);

    $elements.each(function(index) {
      var $element = $(this);
      var $nextPageLink = $element.find('[rel="next"]');

      that.instances.push( $element );

      if ( $element.length && $nextPageLink.length ) {
        var nextPageUrl = $nextPageLink.attr('href');
        var nextPageLinkOffset = $nextPageLink.position().top;
        var scrollOffsetPoint = App.windowHeight * 2;

        $(window).on('resize.infiniteLoader', function() {
          scrollOffsetPoint = App.windowHeight * 2;
        });

        $scrollListener.on('scroll.infiniteLoader', function() {
          if ( $element.data('disabled') ) return;

          var scrollTop = $scrollListener.scrollTop();

          if ( nextPageLinkOffset - scrollTop < scrollOffsetPoint ) {
            $nextPageLink.trigger('click').after('<div class="loading-indicator col-sm-12 text-center"><span class="glyphicon glyphicon-hourglass"></span> Loading...</div>');

            $.get(nextPageUrl, function(data) {
              var content = $(data).find('[data-infinite-load]').html();

              $nextPageLink.remove();
              $element.find('.loading-indicator').remove();
              $element.append(content);
              $nextPageLink = $element.find('[rel="next"]');

              if ( $nextPageLink.length ) {
                nextPageUrl = $nextPageLink.attr('href');
                nextPageLinkOffset = $nextPageLink.position().top;
                $element.data('disabled', false);
                $scrollListener.trigger('scroll.infiniteLoader');
              } else {
                $scrollListener.off('scroll.infiniteLoader');
                $(window).off('resize.infiniteLoader');
              }
            });

            $element.data('disabled', true);
          }
        });
      } else {
        for ( var i = this.scrollListeners.length - 1; i >= 0; i-- ) {
          this.scrollListeners[i].off('scroll.infiniteLoader');
        }
        $(window).off('resize.infiniteLoader');
      }
    });

    $(document).one('turbolinks:before-cache.infiniteLoader', function() {
      that.teardown();
    });
  },
  unbindScroll: function($element) {
    $element.off('scroll.infiniteLoader');
  },
  teardown: function() {
    for ( var i = this.scrollListeners.length - 1; i >= 0; i-- ) {
      this.scrollListeners[i].off('scroll.infiniteLoader');
    }
    if ( this.instances.length ) {
      $(window).off('resize.infiniteLoader');
    }
    this.instances = [];
    this.scrollListeners = [];
  }
};

App.pageLoad.push(function() {
  App.InfiniteLoader.initialize( $('[data-infinite-load]') );
});
