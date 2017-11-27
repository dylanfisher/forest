App.MarkdownTextEditor = {
  instances: [],
  initialize: function($textAreas) {
    var that = this;

    $(document).one('turbolinks:before-cache.markdownTextEditor', function() {
      that.teardown();
    });

    $textAreas.each(function() {
      var $textArea = $(this);
      var placeholder = $textArea.attr('placeholder');

      if ( ( $textArea.data('forest') && $textArea.data('forest').markdownInitialized ) || $textArea.closest('.CodeMirror').length ) {
        return;
      }

      $textArea.data('forest') || $textArea.data('forest', {});
      $textArea.data('forest', { markdownInitialized: true });

      var editor = new SimpleMDE({
        element: this,
        placeholder: placeholder,
        spellChecker: false,
        status: false,
        autoDownloadFontAwesome: false,
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
          {
            name: 'guide',
            action: 'https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet',
            className: 'fa fa-question-circle',
            title: 'Markdown Guide',
            default: true
          },
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
      });

      editor.codemirror.options.extraKeys['Tab'] = false;
      editor.codemirror.options.extraKeys['Shift-Tab'] = false;

      that.instances.push( editor );
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
  App.MarkdownTextEditor.initialize( $('.block_slots .form-group.text textarea, .markdown-editor') );
});

$(document).on('app:block-slot-after-insert', function(event, nestedFields) {
  App.MarkdownTextEditor.initialize( $(nestedFields).find('.form-group.text textarea') );
});
