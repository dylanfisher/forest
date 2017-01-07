$(document).on('change', '.select-tag--default', function() {
  $(this).closest('.select-tag-form').submit();
});

$(document).on('submit', '.select-tag-form', function(e) {
  e.preventDefault();

  var separator = this.action.indexOf('?') == -1 ? '?' : '&';
  var url = [this.action, $(this).serialize()].join(separator);

  Turbolinks.visit(url);
});

// App.pageLoad.push(function() {
//   var $placeholder;

//   $('.select-tag--default').each(function() {
//     var $select = $(this);
//     var title = $select.attr('data-form-title');
//     var placeholder = {
//       id: '',
//       text: title
//     };
//     var allowClear = true;

//     if ( !title ) {
//       placeholder = false;
//       allowClear = false;
//     }

//     $select.select2({
//       placeholder: placeholder,
//       allowClear: allowClear,
//       minimumResultsForSearch: Infinity
//     });
//   });
// });
