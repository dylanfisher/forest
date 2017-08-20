App.pageLoad.push(function() {
  $('[data-toggle="tooltip"]').tooltip();
});

App.teardown.push(function() {
  $('[data-toggle="tooltip"]').tooltip('destroy');
});
