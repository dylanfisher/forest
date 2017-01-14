//////////////////////////////////////////////////////////////
// App Namespace
//////////////////////////////////////////////////////////////

var App = {
  pageLoad: [],
  pageResize: [],
  pageScroll: [],
  runFunctions: function(array){
    for(var i = 0; i < array.length; i++) {
      array[i]();
    }
  }
};

//////////////////////////////////////////////////////////////
// On Page load
//////////////////////////////////////////////////////////////

$(document).on('turbolinks:load', function() {
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
// On Resize
//////////////////////////////////////////////////////////////

$(window).on('resize', function() {
  App.windowWidth  = $(window).width();
  App.windowHeight = $(window).height();

  App.runFunctions(App.pageResize);
});
