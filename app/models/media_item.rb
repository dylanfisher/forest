class MediaItem < Forest::ApplicationRecord
  include FileUploader::Attachment(:attachment)
  include Sluggable

  DATE_FILTER_CACHE_KEY = 'forest_media_item_dates_for_filter'
  CONTENT_TYPE_CACHE_KEY = 'forest_media_item_content_types_for_filter'

  # TODO
  # after_commit :expire_cache

  has_many :pages, foreign_key: :featured_image_id

  validates_presence_of :attachment

  before_save :set_default_metadata
  # before_save :create_derivatives

  enum media_item_status: {
    is_not_hidden: 0,
    hidden: 1
  }

  scope :by_content_type, -> (content_type) { where(attachment_content_type: content_type) }
  scope :images, -> { where('attachment_content_type LIKE ?', '%image%') }
  scope :videos, -> { where('attachment_content_type LIKE ?', '%video%') }
  scope :audio, -> { where('attachment_content_type LIKE ?', '%audio%') }
  scope :pdfs, -> { where('attachment_content_type LIKE ?', '%pdf%') }
  scope :by_date, -> (date) {
    # TODO: why this rescue block?
    begin
      date = Date.parse(date)
      where('media_items.created_at >= ? AND media_items.created_at <= ?', date.beginning_of_month, date.end_of_month)
    rescue ArgumentError => e
      date = nil
    end
  }

  def self.resource_description
    'Media items consist of image, video and other file uploads.'
  end

  def self.dates_for_filter
    Rails.cache.fetch DATE_FILTER_CACHE_KEY do
      self.grouped_by_year_month.collect { |x| [x.created_at.strftime('%B %Y'), x.created_at.strftime('%d-%m-%Y')] }.reverse
    end
  end

  def self.content_types_for_filter
    Rails.cache.fetch CONTENT_TYPE_CACHE_KEY do
      self.grouped_by_content_type.collect { |x| x.attachment_content_type }
    end
  end

  def self.expire_cache!
    Rails.cache.delete self::DATE_FILTER_CACHE_KEY
    Rails.cache.delete self::CONTENT_TYPE_CACHE_KEY
  end

  def self.localizable_params
    [:alternative_text, :caption]
  end

  def self.localized_params
    ( Array(I18n.available_locales) - Array(I18n.default_locale) ).collect do |locale|
      localizable_params.collect { |p| :"#{p}_#{locale}" }
    end.flatten.reject(&:blank?)
  end

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
    # if image?
    #   'glyphicon-picture'
    # elsif video?
    #   'glyphicon-play'
    # elsif attachment_content_type == 'application/zip'
    #   'glyphicon-folder-close'
    # else
    #   'glyphicon-file'
    # end
  end

  def file_extension
    File.extname(attachment_file_name).downcase
  end

  def display_file_name
    attachment_file_name.sub(/(--\d*)?#{Regexp.quote(file_extension)}$/i, '')
  end

  def attachment_content_type
    attachment_data['metadata']['mime_type']
  end

  def attachment_file_name
    # binding.pry if attachment_data.blank? || attachment_data['metadata'].blank?
    attachment_data['metadata']['filename']
  end

  def image?
    (attachment_content_type =~ %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}).present?
  end

  def video?
    (attachment_content_type =~ %r{^video\/}).present?
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

  # TODO: re-implement dimensions with Shrine
  # Portrait images have a lower aspect ratio
  def aspect_ratio
    dimensions[:width].to_f / dimensions[:height].to_f
  end

  def landscape?(ratio = 1)
    aspect_ratio > ratio
  end

  def portrait?(ratio = 1)
    !landscape?(ratio)
  end

  def to_select2_response
    # TODO
    img_tag = ''
    # img_tag = "<img src='#{attachment_url(:thumb)}' style='height: 50px;'> " if image? && attachment.present?
    "#{img_tag}<span class='select2-response__id'>#{id}</span> #{to_label}"
  end

  def to_select2_selection
    # TODO
    img_tag = ''
    # img_tag = "<img src='#{attachment_url(:thumb)}' style='height: 20px; display: inline-block; vertical-align: top;'> " if image? && attachment.present?
    "#{img_tag}<span class='select2-response__id'>#{id}</span> #{to_label}"
  end

  # def create_derivatives
  #   # Create Shrine derivatives using the FileUploader class
  #   # attachment_derivatives! if attachment_changed? && valid?

  #   return unless (valid? && attachment.image?) && (attachment_changed? || attachment_derivatives.blank?)

  #   AttachmentDerivativeJob.perform_later(attachment_attacher.class.name, attachment_attacher.record.class.name, attachment_attacher.record.id, attachment_attacher.name, attachment_attacher.file_data)
  # end

  private

  def self.grouped_by_year_month
    self.select("DISTINCT ON (DATE_TRUNC('month', media_items.created_at)) *")
  end

  def self.grouped_by_content_type
    self.select("DISTINCT ON (media_items.attachment_content_type) *")
  end

  def set_default_metadata
    if self.title.blank?
      self.title = display_file_name
    end
  end

  def expire_cache
    self.class.expire_cache!
  end
end
