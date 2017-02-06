class Menu < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  def structure_as_json
    JSON.parse (structure.presence || '[]')
  end

  private

    def should_generate_new_friendly_id?
      slug.blank?
    end
end
