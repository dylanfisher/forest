// Tab templates
//
// Tab templates use a database column to determine which "template" to use for a particular
// field set. Each "template" consists of a series of Bootstrap tabs. The inputs in all tabs
// except for the active tab will be disabled on form submit, so that only the relevant data
// for the active tab template is saved.

(function() {
  var index = 0;

  var generateUniqueId = function($el) {
    var $tabs = $el.find('[data-toggle="tab"][data-generate-unique-id-for-key]');
    var $panes = $el.find('.tab-pane[data-generate-unique-id-for-key]');

    index++;

    $tabs.each(function() {
      var $tab = $(this);
      var key = $tab.attr('data-generate-unique-id-for-key');
      var $pane = $panes.filter('[data-generate-unique-id-for-key="' + key + '"]');

      if ( !$pane.length ) {
        console.warn('Could not find the matching pane for this key', key);
        return;
      }

      var uniqueId = key + '_' + index;

      $tab.attr('href', '#' + uniqueId);
      $pane.attr('id', uniqueId);
    });
  };

  $(document).on('turbolinks:load', function() {
    index = 0;

    $('.has-tab-template').each(function() {
      generateUniqueId( $(this) );
    });
  });

  $(document).on('cocoon:after-insert', function(e, el) {
    generateUniqueId( $(el) );
  });
})();

$(document).on('submit', 'form', function(e) {
  var $tabTemplates = $('.has-tab-template');

  if ( $tabTemplates.length ) {
    $tabTemplates.each(function() {
      var $tabTemplate = $(this);
      var $panes = $tabTemplate.find('.tab-pane');
      var $inactivePanes = $panes.not('.active');

      $inactivePanes.each(function() {
        var $inactivePane = $(this);
        var $inputs = $inactivePane.find(':input');

        $inputs.prop('disabled', true);
      });
    });
  }
});
