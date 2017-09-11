class MediaItem < Forest::ApplicationRecord
  include Rails.application.routes.url_helpers
  include Attachable
  include Searchable
  include Sluggable

  validates_attachment_presence :attachment

  before_validation :set_default_metadata

  has_many :image_gallery_block_images, foreign_key: :image_id, dependent: :destroy

  scope :by_date, -> (date) {
    begin
      date = Date.parse(date)
      where('created_at >= ? AND created_at <= ?', date.beginning_of_month, date.end_of_month)
    rescue ArgumentError => e
      date = nil
    end
  }

  def self.dates_for_filter
    self.grouped_by_year_month.collect { |x| [x.created_at.strftime('%B %Y'), x.created_at.strftime('%d-%m-%Y')] }.reverse
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

  private

    def self.grouped_by_year_month
      self.select("DISTINCT ON (DATE_TRUNC('month', media_items.created_at)) *")
    end

    def self.grouped_by_content_type
      self.select("DISTINCT ON (media_items.attachment_content_type) *")
    end
end
