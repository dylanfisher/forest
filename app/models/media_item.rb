class MediaItem < ApplicationRecord
  include Forest::Engine.routes.url_helpers

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  has_attached_file :attachment, styles: { large: '1200x1200>', medium: '600x600>', thumb: '100x100>' }, default_url: '/images/:style/missing.png'
  validates_attachment_content_type :attachment, content_type: /\Aimage\/.*\z/
  validates_attachment_presence :attachment

  before_save :set_default_metadata

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
  scope :images, -> { where('attachment_content_type LIKE ?', '%image%') }

  def self.dates_for_filter
    self.grouped_by_year_month.collect { |x| [x.created_at.strftime('%B %Y'), x.created_at.strftime('%d-%m-%Y')] }
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

  private

    def self.grouped_by_year_month
      self.select("DISTINCT ON (DATE_TRUNC('month', created_at)) *")
    end

    def slug_candidates
      [
        :title,
        :id,
        [:id, :attachment_file_name]
      ]
    end

    def should_generate_new_friendly_id?
      slug.blank?
    end

    def set_default_metadata
      if self.title.blank?
        self.title = attachment_file_name.sub(/\.(jpg|jpeg|png|gif)$/i, '')
      end
    end
end
