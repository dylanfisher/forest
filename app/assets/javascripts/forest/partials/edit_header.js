$(document).on('click', '.update-record-button', function() {
  var $form = $('form[class*="edit_"]:first');
  var $submitButton = $form.find('input[type="submit"]:last');

  $submitButton.trigger('click');
});

App.pageLoad.push(function() {
  var $fixedButton = $('#fixed-update-record-button');

  if ( !$fixedButton.length ) return;

  App.pageScroll.push($.throttle( 500, function() {
    if ( App.scrollTop > App.windowHeight / 2 ) {
      $fixedButton.addClass('fixed-update-record-button--active');
    } else {
      $fixedButton.removeClass('fixed-update-record-button--active');
    }
  }));
});
