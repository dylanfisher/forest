class Setting < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  scope :by_id, -> (orderer = :asc) { order(id: orderer) }
  scope :by_title, -> (orderer = :asc) { order(title: orderer) }
  scope :by_slug, -> (orderer = :asc) { order(slug: orderer) }
  scope :by_created_at, -> (orderer = :desc) { order(created_at: orderer) }

  def self.for(title)
    self.settings.select { |setting| setting.slug == title.to_s }.first
  end

  private

    def self.settings
      @settings ||= Rails.cache.fetch Setting.all.cache_key do
        Setting.all.to_a
      end
    end

    def should_generate_new_friendly_id?
      slug.blank?
    end
end
