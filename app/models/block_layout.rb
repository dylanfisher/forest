class BlockLayout < Forest::ApplicationRecord
  include Sluggable

  has_many :block_slots

  validates_presence_of :display_name

  scope :default_layout, -> { BlockLayout.find_by_slug('default') }

  def slug_attribute
    display_name
  end
end
