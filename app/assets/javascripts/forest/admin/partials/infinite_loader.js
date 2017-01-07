App.pageLoad.push(function() {
  var $infiniteLoader = $('[data-infinite-load]');
  var $nextPageLink = $infiniteLoader.find('[rel="next"]');

  if ( $infiniteLoader.length && $nextPageLink.length ) {
    var nextPageUrl = $nextPageLink.attr('href');
    var nextPageLinkOffset = $nextPageLink.offset().top;
    var scrollOffsetPoint = App.windowHeight * 2;

    $(window).on('resize.infiniteLoader', function() {
      scrollOffsetPoint = App.windowHeight * 2;
    });

    $(window).on('scroll.infiniteLoader', function() {
      if ( $infiniteLoader.data('disabled') ) return;

      if ( nextPageLinkOffset - App.scrollTop < scrollOffsetPoint ) {
        $nextPageLink.trigger('click').after('<div class="loading-indicator col-sm-12 text-center"><span class="glyphicon glyphicon-hourglass"></span> Loading...</div>');

        $.get(nextPageUrl, function(data) {
          var content = $(data).find('[data-infinite-load]').html();

          $nextPageLink.remove();
          $infiniteLoader.find('.loading-indicator').remove();
          $infiniteLoader.append(content);
          $nextPageLink = $infiniteLoader.find('[rel="next"]');

          if ( $nextPageLink.length ) {
            nextPageUrl = $nextPageLink.attr('href');
            nextPageLinkOffset = $nextPageLink.offset().top;
            $infiniteLoader.data('disabled', false);
            $(window).trigger('scroll.infiniteLoader');
          } else {
            $(window).off('scroll.infiniteLoader resize.infiniteLoader');
          }
        });

        $infiniteLoader.data('disabled', true);
      }
    });
  } else {
    $(window).off('scroll.infiniteLoader resize.infiniteLoader');
  }

  $(window).trigger('scroll.infiniteLoader');
});
