import $ from 'jquery';
import 'select2';

require('jquery-ui/ui/widgets/sortable');

$.fn.select2.defaults.set('theme', 'bootstrap4');

$(function() {
  var $elements = $('select').filter(':visible');

  $elements.each(function() {
    var $select = $(this);
    var remotePath = $select.attr('data-remote-path');
    var allowClear = $select.find('option:first:empty').length;
    var placeholder = $select.attr('placeholder');
    placeholder = (placeholder == 'false' ? false : (placeholder || ''));
    var selectOptions = {
      allowClear: allowClear,
      placeholder: placeholder
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

    if ( $select.attr('data-sortable') == 'true' ) {
      App.Select2.sortable( $select );
    }
  });
});
