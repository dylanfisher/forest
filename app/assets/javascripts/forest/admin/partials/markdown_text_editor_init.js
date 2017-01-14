App.MarkdownTextEditor = {
  instances: [],
  initialize: function($textAreas) {
    var that = this;
    $textAreas.each(function() {
      that.instances.push( new SimpleMDE({
        element: this,
        hideIcons: ['preview', 'side-by-side', 'fullscreen'],
        spellChecker: false,
        status: false,
        shortcuts: {
          'toggleCodeBlock': null,
          'drawImage': null,
          'toggleOrderedList': null,
          'toggleHeadingBigger': null,
          'toggleSideBySide': null,
          'toggleFullScreen': null,
          'togglePreview': null,
          'toggleHeadingSmaller': null,
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
