class BlockLayout < Forest::ApplicationRecord
  include Sluggable

  has_many :block_slots, inverse_of: :block_layout

  validates_presence_of :display_name

  scope :default_layout, -> { BlockLayout.find_by_slug('default') }

  # def self.default_layout
  #   @default_alyout ||= BlockLayout.find_by_slug('default')
  # end

  def self.resource_description
    "A block layout is a grouping of blocks that may appear in a particular part of the page. For example, you may have block layouts that apply to the sidebar or header areas of a page."
  end

  def slug_attribute
    display_name
  end
end
