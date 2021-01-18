// Localized tab panels

$(document).on('click', '.locale-tab', function() {
  var $tab = $(this);
  var locale = $tab.attr('data-locale');
  var $panels = $('.locale-panel');
  var $activePanels = $panels.filter('[data-locale="' + locale + '"]');
  var $inactivePanels = $panels.not($activePanels);

  $inactivePanels.hide();
  $activePanels.show();

  App.MarkdownTextEditor.initialize( $activePanels.find('.markdown-editor').filter(':visible') );
});

$(document).on('forest:block-slot-after-insert', function(event, nestedFields) {
  var $localeSelector = $('#locale-selection');

  if ( !$localeSelector.length ) return;

  var locale = $localeSelector.find('.nav > li.active .locale-tab').attr('data-locale');
  var $panels = $(nestedFields).find('.locale-panel');

  if ( !$panels.length ) return;

  var $activePanels = $panels.filter('[data-locale="' + locale + '"]');
  var $inactivePanels = $panels.not($activePanels);

  $inactivePanels.hide();
  $activePanels.show();
});

