class BaseBlock < Forest::ApplicationRecord
  self.abstract_class = true

  has_paper_trail class_name: 'BlockVersion',
                  meta: {
                    # block_record_version: :set_block_record_version
                  }

  before_save :set_block_record_version

  has_one :block_slot, class_name: 'BlockSlot', foreign_key: 'block_id'

  def self.display_name
    'Base Block'
  end

  def self.display_icon
    'glyphicon glyphicon-tree-conifer'
  end

  def display_name
    self.class.display_name
  end

  def display_icon
    self.class.display_icon
  end

  def permitted_params
    self.class.permitted_params
  end

  # TODO: association to represent this?
  def block_record
    @block_record ||= block_slot.block_record
  end

  # TODO: association to represent this?
  def block_record_id
    block_record.block_record.id
  end

  def update_block_record_version!
    self.versions.last.update_columns(block_record_version: self.block_record.latest_version_number)
  end

  private

    def set_block_record_version
      # binding.pry
      # self.block_record.latest_version_number
    end
end
