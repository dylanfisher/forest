module Attachable
  extend ActiveSupport::Concern

  included do
    has_attached_file :attachment,
                        styles: {
                          thumb: '200x200#',
                          small: '600x600>',
                          medium: '1200x1200>',
                          large: '2000x2000>'
                        },
                        convert_options: {
                          thumb:  lambda { |r| r.gif? ? '' : '-unsharp 0x1' },
                          small:  lambda { |r| r.gif? ? '' : '-unsharp 0x1' },
                          medium: lambda { |r| r.gif? ? '' : '-unsharp 1.5x1+0.7+0.02' },
                          large:  lambda { |r| r.gif? ? '' : '-unsharp 1.5x1+0.7+0.02' },
                          all:    lambda { |r| r.gif? ? '-strip -auto-orient -colorspace sRGB' : '-strip -auto-orient -quality 85 -colorspace sRGB -interlace Plane' }
                        },
                        default_url: '/images/:style/missing.png'

      do_not_validate_attachment_file_type :attachment

      before_post_process :skip_for_non_images
      after_post_process :extract_dimensions
      after_post_process :collect_garbage

      serialize :dimensions

      belongs_to :attachable, polymorphic: true, optional: true

      scope :by_content_type, -> (content_type) { where(attachment_content_type: content_type) }
      scope :images, -> { where('attachment_content_type LIKE ?', '%image%') }
      scope :videos, -> { where('attachment_content_type LIKE ?', '%video%') }

      def large_attachment_url
        attachment.url(:large)
      end

      def image?
        (attachment_content_type =~ %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}).present?
      end

      def video?
        (attachment_content_type =~ %r{^video\/}).present?
      end

      def file?
        !image?
      end

      def gif?
        attachment_content_type == 'image/gif'
      end

      private

        def set_default_metadata
          if self.title.blank?
            self.title = attachment_file_name.sub(/\.(jpg|jpeg|png|gif)$/i, '')
          end
        end

        def skip_for_non_images
          image?
        end

        # Retrieves dimensions for image assets
        # @note Do this after resize operations to account for auto-orientation.
        # https://github.com/thoughtbot/paperclip/wiki/Extracting-image-dimensions
        def extract_dimensions
          return unless image?
          tempfile = attachment.queued_for_write[:original]
          unless tempfile.nil?
            geometry = Paperclip::Geometry.from_file(tempfile)
            self.dimensions = {
              width: geometry.width.to_i,
              height: geometry.height.to_i
            }
          end
        end

        # Not sure if this is a good idea, but Heroku's memory gets bogged down immediately
        # when using paperclip and imagemagick.
        def collect_garbage
          GC.start
        end
  end
end
