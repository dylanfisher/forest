//////////////////////////////////////////////////////////////
// App namespace
//////////////////////////////////////////////////////////////

window.App = window.App || {};

App.pageLoad = [];
App.pageResize = [];
App.pageScroll = [];
App.runFunctions = function(array) {
  for (var i = array.length - 1; i >= 0; i--) {
    array[i]();
  }
};

//////////////////////////////////////////////////////////////
// On page load
//////////////////////////////////////////////////////////////

$(function() {
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
