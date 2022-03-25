// Localized tab panels

App.pageLoad.push(function() {
  var $panels = $('.locale-panel');

  $(document).on('click', '.locale-tab', function() {
    var $tab = $(this);
    var locale = $tab.attr('data-locale');
    var $activePanels = $panels.filter('[data-locale="' + locale + '"]');
    var $inactivePanels = $panels.not($activePanels);

    $inactivePanels.hide();
    $activePanels.show();

    App.MarkdownTextEditor.initialize( $activePanels.find('.markdown-editor').filter(':visible') );
  });

  $(document).on('forest:block-slot-after-insert', function(event, nestedFields) {
    var $localeSelector = $('#locale-selection');

    if ( !$localeSelector.length ) return;

    var locale = $localeSelector.find('.nav .active').attr('data-locale');

    $panels = $('.locale-panel');

    var $activePanels = $panels.filter('[data-locale="' + locale + '"]');
    var $inactivePanels = $panels.not($activePanels);

    $inactivePanels.hide();
    $activePanels.show();
  });
});
