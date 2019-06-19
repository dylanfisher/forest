$(document).on('click.mediaItemPointOfInterest', '#media-item__point-of-interest', function(e) {
  var $wrapper = $(this);
  var $inputX = $wrapper.find('#media_item_point_of_interest_x');
  var $inputY = $wrapper.find('#media_item_point_of_interest_y');
  var $point = $wrapper.find('#media-item__point-of-interest__crosshair');
  var parentOffset = $wrapper.offset();
  var parentWidth = $wrapper.width();
  var parentHeight = $wrapper.height();
  var x = Math.round( ( (e.pageX - parentOffset.left) / parentWidth * 100 ) * 10 ) / 10;
  var y = (e.pageY - parentOffset.top) / parentHeight * 100;

  $point.css({
    left: x + '%',
    top: y + '%'
  });

  $inputX.val(x);
  $inputY.val(y);
});
