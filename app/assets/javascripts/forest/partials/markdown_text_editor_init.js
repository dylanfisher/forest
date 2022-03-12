// EasyMDE - Markdown Editor
// https://github.com/Ionaru/easy-markdown-editor

(function() {
  var insertMediaItem = function(instance, changeObj, $textArea) {
    var $mediaItemChooser = $('#media-item-chooser');

    $mediaItemChooser.modal('show');

    var cursor = instance.doc.getCursor();
    var prevPos = {
      line: cursor.line,
      ch: cursor.ch - 1
    };

    $(document).on('click.markdownImageUpload', '#media-item-chooser .media-library-link', function(e) {
      e.preventDefault();
      var id = $(this).attr('data-media-item-id');
      instance.doc.replaceRange(id, prevPos);
      $mediaItemChooser.modal('hide');
      $(document).off('click.markdownImageUpload');
    });
  };

  App.MarkdownTextEditor = {
    instances: [],
    initialize: function($textAreas) {
      var that = this;

      $textAreas.each(function() {
        var $textArea = $(this);
        var placeholder = $textArea.attr('placeholder');

        if ( ( $textArea.data('forest') && $textArea.data('forest').markdownInitialized ) || $textArea.closest('.CodeMirror').length ) {
          return;
        }

        $textArea.data('forest') || $textArea.data('forest', {});
        $textArea.data('forest', { markdownInitialized: true });

        var imageUploadToolbarObj = {
          name: 'image',
          title: 'Insert media item shortcode',
          action: EasyMDE.drawImage,
          className: 'fa fa-image'
        };
        var imageUpload = $textArea.hasClass('markdown-editor--image-upload') ? imageUploadToolbarObj : undefined;
        var blockquote = $textArea.hasClass('markdown-editor--blockquote') ? 'quote' : undefined;
        var noToolbar = $textArea.hasClass('markdown-editor--no-toolbar') ? true : false;
        var toolbarOptions = [
          'bold',
          'italic',
          'heading',
          blockquote,
          '|',
          'unordered-list',
          'ordered-list',
          '|',
          'link',
          imageUpload,
          '|',
          {
            name: 'guide',
            action: 'https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet',
            className: 'fa fa-question-circle',
            title: 'Markdown Guide',
            default: true
          },
        ];

        toolbarOptions = toolbarOptions.filter(function(x) {
          return x !== undefined;
        });

        if ( noToolbar ) toolbarOptions = false;

        var editor = new EasyMDE({
          element: this,
          placeholder: placeholder,
          spellChecker: false,
          status: false,
          autoDownloadFontAwesome: false,
          minHeight: '150px',
          toolbar: toolbarOptions,
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
          },
          insertTexts: {
            image: ["[MEDIA_ITEM=", "]"],
          }
        });

        editor.codemirror.options.extraKeys['Tab'] = false;
        editor.codemirror.options.extraKeys['Shift-Tab'] = false;

        editor.codemirror.on('change', function(instance, changeObj) {
          if ( changeObj.text && changeObj.text[0] == '[MEDIA_ITEM=]' ) {
            insertMediaItem(instance, changeObj, $textArea);
          }
        });

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
    App.MarkdownTextEditor.initialize( $('.markdown-editor').filter(':visible') );
  });
})();

$(document).on('forest:block-slot-after-insert', function(event, nestedFields) {
  App.MarkdownTextEditor.initialize( $(nestedFields).find('.form-group.text .markdown-editor').filter(':visible') );
});

$(document).on('shown.bs.tab', 'a[data-toggle="tab"]', function(e) {
  var $tab = $(e.target);
  var tabId = $tab.attr('href');
  var $tabContent = $(tabId);

  App.MarkdownTextEditor.initialize( $tabContent.find('.markdown-editor').filter(':visible') );
});

$(document).on('app:show-collapsed-content', function(e, el) {
  App.MarkdownTextEditor.initialize( $(el).find('.markdown-editor').filter(':visible') );
});
