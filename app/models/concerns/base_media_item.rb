module BaseMediaItem
  extend ActiveSupport::Concern

  included do
    include FileUploader::Attachment(:attachment)
    include Sluggable

    DATE_FILTER_CACHE_KEY = 'forest_media_item_dates_for_filter'
    CONTENT_TYPE_CACHE_KEY = 'forest_media_item_content_types_for_filter'

    after_commit :reprocess_derivatives, on: :update, if: Proc.new { |x| x.previous_changes[:retain_source].present? }

    has_many :pages, foreign_key: :featured_image_id
    has_many :poster_images, foreign_key: :poster_image_id, class_name: 'MediaItem', dependent: :nullify

    belongs_to :poster_image, class_name: 'MediaItem', optional: true

    validates_presence_of :attachment

    before_save :set_default_metadata

    enum :media_item_status, {
      is_not_hidden: 0,
      hidden: 1
    }

    scope :by_content_type, -> (content_type) { where(attachment_content_type: content_type) }
    scope :by_extension, -> (extension) {
      extension_pattern = ".*#{Regexp.escape(extension)}$"
      where("attachment_data->'metadata'->>'filename' ~ ?", extension_pattern)
    }
    # This layout scope is a NOOP that exists to make it easier to use the `current_scopes` method
    scope :layout, -> (layout_name) { }
    scope :images, -> { where('attachment_content_type LIKE ?', '%image%') }
    scope :videos, -> { where('attachment_content_type LIKE ?', '%video%') }
    scope :audio, -> { where('attachment_content_type LIKE ?', '%audio%') }
    scope :pdfs, -> { where('attachment_content_type LIKE ?', '%pdf%') }
    scope :by_date, -> (date) {
      date = Date.parse(date)
      where('media_items.created_at >= ? AND media_items.created_at <= ?', date.beginning_of_month, date.end_of_month)
    }
    scope :missing_all_derivatives, -> { where("(attachment_data->'derivatives') is null") }
    scope :missing_some_derivatives, -> { where("(attachment_data->'derivatives') is null") }
  end

  class_methods do
    def resource_description
      'Media items consist of image, video and other file uploads.'
    end

    def dates_for_filter
      Rails.cache.fetch [DATE_FILTER_CACHE_KEY, cache_key], expires_in: 4.weeks do
        self.grouped_by_year_month.collect { |x| [x.created_at.strftime('%B %Y'), x.created_at.strftime('%d-%m-%Y')] }.reverse
      end
    end

    def content_types_for_filter
      Rails.cache.fetch [CONTENT_TYPE_CACHE_KEY, cache_key], expires_in: 4.weeks do
        self.grouped_by_content_type.collect { |x| x.attachment_content_type }
      end
    end

    def localizable_params
      [:alternative_text, :caption]
    end

    def localized_params
      ( Array(I18n.available_locales) - Array(I18n.default_locale) ).collect do |locale|
        localizable_params.collect { |p| :"#{p}_#{locale}" }
      end.flatten.reject(&:blank?)
    end

    # Override this method if you want to do additional processing of a media item after it is saved,
    # for example processing audio metadata of an uploaded mp3 file, or analyzing color information
    # of an image.
    def after_save_callbacks
    end

    # Override this method to add additional permitted params to the Admin::MediaItemsController
    def additional_permitted_params
      []
    end

    def reprocess_all_derivatives!
      # TODO: This doesn't seem to reprocess the derivatives, it just clears them. DRY this
      # up by using the instance methods reprocess_derivatives
      # Reprocessing all derivatives
      # https://shrinerb.com/docs/changing-derivatives#reprocessing-all-derivatives

      # TODO: move this to background job?
      MediaItem.find_each do |media_item|
        attacher = media_item.attachment_attacher

        next unless attacher.stored? && media_item.image?

        old_derivatives = attacher.derivatives

        attacher.set_derivatives({})                    # clear derivatives
        attacher.create_derivatives                     # reprocess derivatives

        begin
          attacher.atomic_persist                       # persist changes if attachment has not changed in the meantime
          attacher.delete_derivatives(old_derivatives)  # delete old derivatives
        rescue Shrine::AttachmentChanged,               # attachment has changed
               ActiveRecord::RecordNotFound             # record has been deleted
          attacher.delete_derivatives if attacher.present? # delete now orphaned derivatives
        end
      end
    end

    def reprocess_missing_derivatives!
      FileUploader::IMAGE_DERIVATIVES.keys.each do |style|
        images_with_issing_derivatives = MediaItem.where("(attachment_data->'derivatives'->'#{style}') is null")
        images_with_issing_derivatives.find_each do |media_item|
          next unless media_item.supports_derivatives?

          media_item.reprocess_derivative(style)
        end
      end
    end

    # Re-transcode all videos, e.g. if you add or change job settings in MediaConvert. Do note that
    # this is a potentially expensive operation depending on how many videos are in your database.
    def retranscode_all_videos!
      MediaItem.videos.each { |v| v.enqueue_transcode_job! }
    end

    private

    def grouped_by_year_month
      self.select("DISTINCT ON (DATE_TRUNC('month', media_items.created_at)) *")
    end

    def grouped_by_content_type
      self.select("DISTINCT ON (media_items.attachment_content_type) *")
    end
  end

  # Instance methods

  def generate_slug
    if self.slug.blank? || changed.include?('slug')
      if title.present?
        slug_attribute = title
      elsif attachment_file_name.present?
        slug_attribute = attachment_file_name
      else
        slug_attribute = SecureRandom.uuid
      end

      slug_attribute = slug_attribute.parameterize

      if MediaItem.where(slug: slug_attribute).present?
        slug_attribute = slug_attribute + '-' + SecureRandom.uuid
      end

      self.slug = slug_attribute
    end
  end

  def glyphicon
    if image?
      'image'
    elsif video?
      if try(:vimeo_video?)
        'play glyphicon-invert'
      else
        'play'
      end
    elsif attachment_content_type == 'application/zip'
      'file-richtext'
    else
      'file-richtext'
    end
  end

  def file_extension
    File.extname(attachment_file_name).downcase
  end

  def display_file_name
    title.presence || attachment_file_name.sub(/(--\d*)?#{Regexp.quote(file_extension)}$/i, '')
  end

  def display_file_name_with_extension
    "<span class=\"media-item-file-name\">#{display_file_name} <span class=\"media-item-file-extension small text-muted\">#{file_extension}</span></span>"
  end

  def get_attachment_content_type
    attachment_data['metadata']['mime_type'] if attachment_data.present?
  end

  def attachment_file_name
    attachment_data['metadata']['filename'] if attachment_data.present?
  end

  def image?
    (attachment_content_type =~ %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|tiff|webp|x-png|svg\+xml)$}).present?
  end

  def svg?
    attachment_content_type =~ %r{^image\/svg\+xml}
  end

  def video?
    (attachment_content_type =~ %r{^video\/}).present?
  end

  def forest_video?
    video_list.present? && video_list.videos.present?
  end

  def audio?
    (attachment_content_type =~ %r{^audio\/}).present?
  end

  def file?
    !image?
  end

  def gif?
    attachment_content_type == 'image/gif'
  end

  def jpeg?
    attachment_content_type =~ %r{^(image)/(jpeg|jpg)}
  end

  def video_list
    @video_list ||= Forest::VideoList.new(video_data) if video_data.present?
  end

  # A media item with content type SVG is considered an image, but it doesn't make sense to generate derivatives for SVGs
  def supports_derivatives?
    (attachment_content_type =~ %r{^(image|(x-)?application)/(bmp|jpeg|jpg|pjpeg|png|webp|x-png)$}).present?
  end

  def display_content_type
    if image?
      'image'
    elsif video?
      'video'
    elsif file?
      'file'
    else
      'media item'
    end
  end

  def dimensions
    {
      width: (video_list.try(:width) || attachment.width.presence || attachment_derivatives[:large].try(:width) || (try(:vimeo_video?) ? vimeo_video_width : nil)),
      height: (video_list.try(:height) || attachment.height.presence || attachment_derivatives[:large].try(:height) || (try(:vimeo_video?) ? vimeo_video_height : nil))
    }
  end

  def width
    dimensions[:width]
  end

  def height
    dimensions[:height]
  end

  # Landscape images have a lower aspect ratio
  def aspect_ratio
    height.to_f / width.to_f
  end

  def landscape?(ratio = 1)
    aspect_ratio < ratio
  end

  def portrait?(ratio = 1)
    !landscape?(ratio)
  end

  def to_label
    display_file_name
  end

  def select2_image_thumbnail
    if image? && attachment.present?
      "<img src='#{attachment_url(:thumb)}' style='height: 21px; margin-right: 5px;'> "
    elsif try(:vimeo_video?) && (vimeo_video_thumbnail_override.present? || vimeo_video_thumbnail(:thumb).present?)
      if vimeo_video_thumbnail_override.present?
        "<img src='#{vimeo_video_thumbnail_override.attachment_url(:thumb)}' style='height: 21px; margin-right: 5px;'> "
      else
        "<img src='#{vimeo_video_thumbnail(:thumb)}' style='height: 21px; margin-right: 5px;'> "
      end
    else
      ''
    end
  end

  def to_select2_response
    "#{select2_image_thumbnail}<span class='select2-response__id' style='margin-right: 5px;'>#{id}</span> #{to_label}"
  end

  def to_select2_selection
    "#{select2_image_thumbnail}<span class='select2-response__id' style='margin-right: 5px;'>#{id}</span> #{to_label}"
  end

  def reprocess_derivatives
    return unless attachment_attacher.stored? && supports_derivatives?

    attachment_attacher.delete_derivatives
    attachment_attacher.set_derivatives({})
    attachment_attacher.atomic_persist

    FileUploader::IMAGE_DERIVATIVES.each_key do |derivative_name|
      reprocess_derivative(derivative_name)
    end
  end

  def reprocess_derivative(derivative_name)
    return unless attachment_attacher.stored? && supports_derivatives?

    attachment_attacher.remove_derivative(derivative_name, delete: true) if attachment_derivatives[derivative_name].present?
    attachment_attacher.atomic_persist

    AttachmentDerivativeJob.perform_later(attachment_attacher.class.name, attachment_attacher.record.class.name, attachment_attacher.record.id, attachment_attacher.name, attachment_attacher.file_data, derivative_name)
  end

  def extract_video_metadata!(include_derivatives: true)
    return unless supports_video_transcoding?

    path_with_just_filename = File.basename(attachment_data['id'])
    path_without_filename = attachment_data['id'].split('/')[0..-2].join('/')
    object_paths = []
    object_paths << "#{Shrine.storages[:store].prefix}/#{attachment_data['id']}"

    if include_derivatives
      video_list.jobs.each do |video_list_file|
        # Derivative extension will always be mp4 after they've been transcoded
        path_with_name_modifier = path_with_just_filename.sub(/\.#{attachment.extension}/, "#{video_list_file['name_modifier']}.mp4")
        object_paths << "#{Shrine.storages[:store].prefix}/#{path_without_filename}/transcoded/#{path_with_name_modifier}"
      end
    end

    object_paths.each do |object_path|
      VideoTranscodeExtractMetadataJob.set(wait: rand(1..30).seconds).perform_later(media_item_id: id, object_path: object_path)
    end
  end

  def enqueue_transcode_job!
    return unless supports_video_transcoding?

    if video_data.class != Hash
      update_columns(video_data: { 'status' => Forest::VideoList::TRANSCODE_STATUS_ENQUEUED })
    elsif video_data['status'] != Forest::VideoList::TRANSCODE_STATUS_ENQUEUED
      update_columns(video_data: video_data.merge('status' => Forest::VideoList::TRANSCODE_STATUS_ENQUEUED))
    end
    VideoTranscodeEnqueueJob.set(wait: rand(1..30).seconds).perform_later(id)
  end

  def destroy_video_list!
    return unless supports_video_transcoding?

    VideoTranscodeDestroyJob.perform_later(video_data) unless Forest.config[:keep_files]
    self.update_columns(video_data: nil) unless self.destroyed?
  end

  def supports_video_transcoding?
    Rails.application.credentials.dig(:aws_media_convert_endpoint).present?
  end

  private

  def set_default_metadata
    if self.title.blank?
      self.title = display_file_name
    end

    self.attachment_content_type = get_attachment_content_type
  end
end
