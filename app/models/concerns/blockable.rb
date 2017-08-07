module Blockable
  extend ActiveSupport::Concern

  included do
    parent_class = self

    # before_save :set_block_slot_versions
    after_destroy :destroy_associated_blocks

    has_many :block_slots, -> { where(block_record_type: parent_class.name).order(:position) }, foreign_key: 'block_record_id'
    # has_one :block_record, as: :block_record, dependent: :destroy

    accepts_nested_attributes_for :block_slots, allow_destroy: true

    # TODO: DF 08/04/17 - under some condition if a block is saved without a block_id, the record will crash

    # TODO: rename block_slots to blocks and get rid of this method?
    def blocks(options = {})
      layout = options.fetch(:layout, nil)

      instance_variable_get("@#{layout}_blocks") || instance_variable_set("@#{layout}_blocks", begin
        if self.try(:versionable?) && self.version.present?
          # TODO: DF 08/06/17 - refactor this!
          version_number = self.version.index
          block_slot_versions = BlockSlotVersion.where(block_record_type: self.class.name, block_record_id: self.id, block_record_version: version_number)
                                                .reject(&:blank?)
                                                .collect { |bs|
                                                  bs.reify
                                                }
          # binding.pry
          if layout.present?
            block_slot_versions.select { |bs| bs.layout == layout.to_s }
                               .collect { |bs| bs.block.versions.where(block_record_version: version_number).first.reify }
          else
            block_slot_versions.collect { |bs| bs.block.versions.where(block_record_version: version_number).first.reify }
          end
        else
          if layout.present?
            block_slots.select { |bs| bs.layout == layout.to_s }.collect(&:block)
          else
            block_slots.collect(&:block)
          end
        end
      end)
    end

    # TODO: make this more performant and/or not as weird
    def reify_block_slots!
      version_number = self.version.index

      reified_block_slots = BlockSlotVersion.where(block_record_type: self.class.name, block_record_id: self.id, block_record_version: version_number)
                                            .collect(&:reify)
                                            .reject(&:blank?)

      reified_block_slots.each { |bs|
        bs.block.versions.where(block_record_version: version_number).first.reify.save
      }

      self.block_slots = reified_block_slots

      # currently this is saved in the controller, otherwise do `self.save` here
    end

    def latest_version_number
      if self.try(:versionable?)
        self.versions.last.try(:index).to_i
      end
    end

    private

      # def set_block_slot_versions
      #   block_slots.find_each { |bs|
      #     bs.update_attributes(block_record_version: latest_version_number)
      #   }
      # end

      def destroy_associated_blocks
        block_slots.includes(:block).each { |block_slot| block_slot.block&.destroy }
        block_slots.destroy_all
      end
  end
end
