module Attachable
  extend ActiveSupport::Concern

  included do
    has_attached_file :attachment,
                        styles: {
                          large: '2000x2000>',
                          medium: '1200x1200>',
                          small: '600x600>'
                        },
                        convert_options: {
                          :all => '-strip -interlace Plane'
                        },
                        default_url: '/images/:style/missing.png'

      do_not_validate_attachment_file_type :attachment

      before_post_process :skip_for_non_images
      after_post_process :extract_dimensions

      serialize :dimensions

      belongs_to :attachable, polymorphic: true

      scope :by_content_type, -> (content_type) { where(attachment_content_type: content_type) }
      scope :images, -> { where('attachment_content_type LIKE ?', '%image%') }

      def self.content_types_for_filter
        self.grouped_by_content_type.collect { |x| x.attachment_content_type }
      end

      def large_attachment_url
        attachment.url(:large)
      end

      def image?
        attachment_content_type =~ %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}
      end

      def file?
        !image?
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
  end
end
