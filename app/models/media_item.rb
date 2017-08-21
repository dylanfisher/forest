class MediaItem < Forest::ApplicationRecord
  include Rails.application.routes.url_helpers
  include Searchable
  include Sluggable

  has_attached_file :attachment,
                    styles: {
                      large: '2000x2000>',
                      medium: '1200x1200>',
                      small: '600x600>' },
                    default_url: '/images/:style/missing.png'

  do_not_validate_attachment_file_type :attachment

  before_post_process :skip_for_non_images
  after_post_process :extract_dimensions

  validates_attachment_presence :attachment

  before_validation :set_default_metadata

  serialize :dimensions

  belongs_to :attachable, polymorphic: true

  has_many :image_gallery_block_images, foreign_key: :image_id, dependent: :destroy

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
      'id': self.id,
      'name': read_attribute(:title),
      'size': attachment.size,
      'url': edit_admin_media_item_path(self),
      'thumbnail_url': attachment.url(:medium),
      'delete_url': admin_media_item_path(id: id),
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

  def image?
    attachment_content_type =~ %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}
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
