//////////////////////////////////////////////////////////////
// App namespace
//////////////////////////////////////////////////////////////

window.App = window.App || {};

App.pageLoad = [];
App.pageResize = [];
App.pageScroll = [];
App.teardown = [];
App.runFunctions = function(array) {
  for (var i = array.length - 1; i >= 0; i--) {
    array[i]();
  }
};

//////////////////////////////////////////////////////////////
// On page load
//////////////////////////////////////////////////////////////

$(document).on('turbolinks:load', function(e) {
  App.scrollTop = $(window).scrollTop();

  App.windowWidth  = $(window).width();
  App.windowHeight = $(window).height();

  App.runFunctions(App.pageLoad);
  App.runFunctions(App.pageResize);
  App.runFunctions(App.pageScroll);
});

//////////////////////////////////////////////////////////////
// On scroll
//////////////////////////////////////////////////////////////

$(window).on('scroll', function() {
  App.scrollTop = $(window).scrollTop();

  App.runFunctions(App.pageScroll);
});

//////////////////////////////////////////////////////////////
// On resize
//////////////////////////////////////////////////////////////

$(window).on('resize', function() {
  App.windowWidth  = $(window).width();
  App.windowHeight = $(window).height();

  App.runFunctions(App.pageResize);
});

//////////////////////////////////////////////////////////////
// On turbolinks:before-cache
//////////////////////////////////////////////////////////////

$(document).on('turbolinks:before-cache', function() {
  App.runFunctions(App.teardown);
});
