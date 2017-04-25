class MediaItem < ApplicationRecord
  include Rails.application.routes.url_helpers
  include Searchable

  # TODO: move paperclip_optimizer gems into forest gemspec, or don't break if this processor is missing
  has_attached_file :attachment,
                    styles: {
                      huge: '2000x2000>',
                      large: '1200x1200>',
                      medium: '600x600>',
                      small: '300x300>',
                      thumb: '100x100>' },
                    default_url: '/images/:style/missing.png',
                    processors: [:thumbnail, :paperclip_optimizer]
  do_not_validate_attachment_file_type :attachment
  before_post_process :skip_for_non_images
  validates_attachment_presence :attachment

  before_validation :set_default_metadata
  before_validation :generate_slug

  validates :slug, presence: true, uniqueness: true

  belongs_to :attachable, polymorphic: true

  scope :by_id, -> (orderer = :desc) { order(id: orderer) }
  scope :by_date, -> (date) {
    begin
      date = Date.parse(date)
      where('created_at >= ? AND created_at <= ?', date.beginning_of_month, date.end_of_month)
    rescue ArgumentError => e
      date = nil
    end
  }
  scope :by_content_type, -> (content_type) { where(attachment_content_type: content_type) }
  scope :images, -> { where('attachment_content_type LIKE ?', '%image%') }

  def self.dates_for_filter
    self.grouped_by_year_month.collect { |x| [x.created_at.strftime('%B %Y'), x.created_at.strftime('%d-%m-%Y')] }.reverse
  end

  def self.content_types_for_filter
    self.grouped_by_content_type.collect { |x| x.attachment_content_type }
  end

  def to_jq_upload
    {
      'name': read_attribute(:attachment_name),
      'size': attachment.size,
      'url': edit_media_item_path(self),
      'thumbnail_url': attachment.url(:medium),
      'delete_url': media_item_path(id: id),
      'delete_type': 'DELETE'
    }
  end

  def large_attachment_url
    attachment.url(:large)
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

      self.slug = slug_attribute.parameterize
    end
  end

  def to_param
    slug
  end

  def image?
    (attachment_content_type =~ /^image\//).present?
  end

  def file?
    !image?
  end

  def glyphicon
    if image?
      'glyphicon-picture'
    elsif attachment_content_type == 'application/zip'
      'glyphicon-folder-close'
    else
      'glyphicon-file'
    end
  end

  private

    def self.grouped_by_year_month
      self.select("DISTINCT ON (DATE_TRUNC('month', media_items.created_at)) *")
    end

    def self.grouped_by_content_type
      self.select("DISTINCT ON (media_items.attachment_content_type) *")
    end

    def set_default_metadata
      if self.title.blank?
        self.title = attachment_file_name.sub(/\.(jpg|jpeg|png|gif)$/i, '')
      end
    end

    def skip_for_non_images
      image?
    end
end
