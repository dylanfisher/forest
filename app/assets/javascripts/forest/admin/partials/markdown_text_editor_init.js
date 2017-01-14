App.MarkdownTextEditor = {
  instances: [],
  initialize: function($textAreas) {
    var that = this;
    $textAreas.each(function() {
      that.instances.push( new SimpleMDE({
        element: this,
        spellChecker: false,
        status: false,
        toolbar: [
          'bold',
          'italic',
          'heading',
          '|',
          'unordered-list',
          'ordered-list',
          '|',
          'link',
          '|',
          'guide',
        ],
        shortcuts: {
          'drawImage': null,
          'drawLink': null,
          'cleanBlock': null,
          'toggleBlockquote': null,
          'toggleCodeBlock': null,
          'toggleFullScreen': null,
          'toggleHeadingBigger': null,
          'toggleHeadingSmaller': null,
          'toggleOrderedList': null,
          'togglePreview': null,
          'toggleSideBySide': null,
          'toggleUnorderedList': null,
        }
      }) );
    });
  },
  teardown: function() {
    for ( var i = this.instances.length - 1; i >= 0; i-- ) {
      this.instances[i].toTextArea();
    }
    this.instances = [];
  }
};

App.pageLoad.push(function() {
  var $textAreas = $('#page_slots .form-group.text textarea');
  App.MarkdownTextEditor.initialize( $textAreas );
});

$(document).on('app:page-slot-after-insert', function(event, nestedFields) {
  App.MarkdownTextEditor.initialize( $(nestedFields).find('.form-group.text textarea') );
});

$(document).on('turbolinks:before-cache.markdownTextEditor', function() {
  App.MarkdownTextEditor.teardown();
});
