class MediaItem < Forest::ApplicationRecord
  include Rails.application.routes.url_helpers
  include Attachable
  include Forest::CacheBuster
  include Sluggable

  DATE_FILTER_CACHE_KEY = 'forest_media_item_dates_for_filter'
  CONTENT_TYPE_CACHE_KEY = 'forest_media_item_content_types_for_filter'

  validates_attachment_presence :attachment

  before_validation :set_default_metadata

  after_save :expire_cache
  after_destroy :expire_cache

  has_many :pages, foreign_key: :featured_image_id

  enum media_item_status: {
    not_hidden: 0,
    hidden: 1
  }

  scope :by_date, -> (date) {
    begin
      date = Date.parse(date)
      where('created_at >= ? AND created_at <= ?', date.beginning_of_month, date.end_of_month)
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
      'glyphicon-picture'
    elsif video?
      'glyphicon-play'
    elsif attachment_content_type == 'application/zip'
      'glyphicon-folder-close'
    else
      'glyphicon-file'
    end
  end

  def to_jq_upload
    {
      'id': self.id,
      'name': read_attribute(:title),
      'size': attachment.size,
      'url': edit_admin_media_item_path(self),
      'thumbnail_url': attachment.url(:medium),
      'delete_url': admin_media_item_path(id: id),
      'delete_type': 'DELETE'
    }
  end

  def landscape?(ratio = 1)
    dimensions[:width].to_f / dimensions[:height].to_f > ratio
  end

  def portrait?(ratio = 1)
    !landscape?(ratio)
  end

  def to_select2_response
    img_tag = "<img src='#{attachment.url(:thumb)}' style='height: 50px;'> " if image? && attachment.present?
    "#{img_tag}<span class='select2-response__id'>#{id}</span> #{to_label}"
  end

  def to_select2_selection
    img_tag = "<img src='#{attachment.url(:thumb)}' style='height: 20px; display: inline-block; vertical-align: top;'> " if image? && attachment.present?
    "#{img_tag}<span class='select2-response__id'>#{id}</span> #{to_label}"
  end

  private

    def self.grouped_by_year_month
      self.select("DISTINCT ON (DATE_TRUNC('month', media_items.created_at)) *")
    end

    def self.grouped_by_content_type
      self.select("DISTINCT ON (media_items.attachment_content_type) *")
    end

    def expire_cache
      self.class.expire_cache!
    end
end
