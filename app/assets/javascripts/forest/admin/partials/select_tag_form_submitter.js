// Default selects
$(document).on('change', '.select-tag--default', function() {
  $(this).closest('.select-tag-form').submit();
});

$(document).on('submit', '.select-tag-form', function(e) {
  e.preventDefault();

  var separator = this.action.indexOf('?') == -1 ? '?' : '&';
  var url = [this.action, $(this).serialize()].join(separator);

  Turbolinks.visit(url);
});

// Remote selects
$(document).on('change', '.select-tag--remote', function() {
  $(this).closest('.select-tag-remote-form').submit();
});

$(document).on('submit', '.select-tag-remote-form', function(e) {
  e.preventDefault();

  var $form = $(this);
  var $select = $form.find('.select-tag--remote');
  var $parent = $form.closest( $select.attr('data-remote-parent') );
  var $target = $parent.find( $select.attr('data-remote-target') );
  var responseTargetSelector = $select.attr('data-remote-response-target');
  var $mediaItemChooser = $form.closest('.media-item-chooser');
  var url = $form.attr('action');

  $.get(url, $form.serialize(), function(data) {
    var content = $(data).find( responseTargetSelector ).html();

    $target.html(content);

    if ( $mediaItemChooser.length ) {
      App.InfiniteLoader.initialize( $mediaItemChooser.find('[data-infinite-load]'), { $scrollListener: $mediaItemChooser } );
    }
  });
});
