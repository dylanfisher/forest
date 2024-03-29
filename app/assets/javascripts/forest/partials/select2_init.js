// Set the default theme for all select2 widgets

$.fn.select2.defaults.set('theme', 'bootstrap4');

App.Select2 = {
  initialize: function($elements) {
    var that = this;

    this.add($elements);
  },
  sortable: function($select2) {
    var ul = $select2.next('.select2-container').first('ul.select2-selection__rendered');

    ul.addClass('is-ui-sortable');

    ul.sortable({
      placeholder: 'ui-state-highlight',
      forcePlaceholderSize: true,
      tolerance: 'pointer',
      scroll: false,
      items: 'li:not(.select2-search)',
      helper: function(e, el) {
        el.width(el.width() + 1);
        return el;
      },
      start: function(e, ui) {
        ui.placeholder.height( ui.item.height() );
      },
      stop: function() {
        $( $(ul).find('.select2-selection__choice').get().reverse() ).each(function() {
          var id = $(this).find('.select2-response__id').attr('data-id');
          var option = $select2.find('option[value="' + id + '"]')[0];

          $select2.prepend(option);
        });
      }
    });
  },
  add: function($elements) {
    var that = this;

    $elements.each(function() {
      var $select = $(this);
      var remotePath = $select.attr('data-remote-path');
      var allowClear = $select.find('option:first:empty').length;
      var placeholder = $select.attr('placeholder');
      placeholder = (placeholder == 'false' ? false : (placeholder || ''));
      var $modal = $select.closest('.modal');
      var dropdownParent = $modal.length ? $modal : undefined;
      var selectOptions = {
        allowClear: allowClear,
        placeholder: placeholder,
        dropdownParent: dropdownParent
      };

      if ( remotePath && remotePath.length ) {
        selectOptions = {
          placeholder: placeholder,
          allowClear: allowClear,
          ajax: {
            url: remotePath,
            dataType: 'json',
            delay: 250,
            data: function (params) {
              var returnObj = {};
              var remoteScope = $select.attr('data-remote-scope'); // TODO: remote scope default?

              // TODO: support multiple scopes

              returnObj[remoteScope] = params.term; // search term
              returnObj['page'] = params.page;

              return returnObj;
            },
            processResults: function (data, params) {
              params.page = params.page || 1;
              return {
                results: data.items,
                pagination: {
                  more: (params.page * data.per_page) < data.total_count
                }
              };
            },
            cache: true,
          },
          escapeMarkup: function (markup) {
            return markup;
          },
          templateResult: function(data) {
            if ( data.loading ) return data.text;
            return data.select2_response;
          },
          templateSelection: function(data) {
            var selection = data.select2_selection;

            if ( !selection ) {
              if ( data.element ) {
                selection = $(data.element).attr('data-select2-selection');
              }
            }

            if ( !selection ) {
              selection = data.select2_response;
            }

            if ( !selection ) {
              if ( data.element ) {
                selection = $(data.element).attr('data-select2-response');
              }
            }

            if ( !selection ) {
              selection = placeholder;
            }

            return selection;
          }
        };
      }

      $select.select2( selectOptions );

      if ( $select.hasClass('country') ) $select.trigger('change');

      if ( $select.attr('data-sortable') == 'true' ) {
        App.Select2.sortable( $select );
      }
    });
  }
};

App.pageLoad.push(function() {
  App.Select2.initialize( $('select').filter(':visible') );
});

$(document).on('change', 'select', function() {
  var $select = $(this);

  if ( $select.hasClass('country') ) {
    var $selectedOption = $select.find('option:selected');
    var $form = $select.closest('form');

    if ( $selectedOption.length && $selectedOption.text().toLowerCase() == 'united states' ) {
      $form.addClass('country--united-states');
    } else {
      $form.removeClass('country--united-states');
    }

    $form.find('.state-input--select input').trigger('change');

    $form.find('.state-input--select select').each(function() {
      var $stateSelect = $(this);

      if ( $stateSelect.is(':visible') ) {
        $stateSelect.removeAttr('disabled');
      } else {
        $stateSelect.prop('disabled', true);
      }

      if ( $stateSelect.data('select2Id') ) return;

      App.Select2.initialize($stateSelect);
    });
  }
});

$(document).on('forest:show-media-item-chooser', function() {
  App.Select2.initialize( $('#media-item-chooser').find('select').filter(':visible') );
});

$(document).on('forest:block-slot-after-insert', function(e, blockSlot) {
  App.Select2.initialize( $(blockSlot).find('select').filter(':visible') );
});

$(document).on('forest:add-menu-item', function(e, $menuItem) {
  App.Select2.add( $menuItem.find('select').filter(':visible') );
});

$(document).on('cocoon:after-insert', function(e, insertedItem) {
  var $item = $(insertedItem);

  if ( $item.hasClass('block-slot') ) return;

  App.Select2.initialize( $(insertedItem).find('select').filter(':visible') );
});

$(document).on('shown.bs.tab', function(e) {
  var $tabContent = $( $(e.target).attr('href') );

  if ( !$tabContent.length ) return;

  App.Select2.add( $tabContent.find('select').filter(':visible') );
});
