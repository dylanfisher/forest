$(document).on('click', '.update-record-button', function() {
  var $form = $('form[class*="edit_"]:first');
  var $submitButton = $form.find('input[type="submit"]:last');

  $submitButton.trigger('click');
});

$(document).on('turbolinks:load', function() {
  var $fixedButton = $('#fixed-update-record-button');

  if ( $fixedButton.length ) {
    $(window).on('scroll.editHeader', $.throttle( 500, function() {
      if ( App.scrollTop > App.windowHeight / 2 ) {
        $fixedButton.addClass('fixed-update-record-button--active');
      } else {
        $fixedButton.removeClass('fixed-update-record-button--active');
      }
    }));
  } else {
    $(window).off('scroll.editHeader');
  }
});
