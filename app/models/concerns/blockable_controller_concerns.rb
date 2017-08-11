module BlockableControllerConcerns
  extend ActiveSupport::Concern

  included do
    before_action :set_block_types, only: [:edit, :new, :create, :update]

    has_scope :by_status
  end

  private

    def set_block_types
      @block_types = BlockType.all.by_name
    end

    def save_record(record, options = {})
      @record ||= record
      @record.save
      set_blocks @record, **options # bad pattern?
    end

    def set_blocks(record, options = {})
      return unless @blocks.present?
      @record ||= record
      @blocks.delete_if { |k, v| v.blank? }.each_pair do |position, block|
        block_slot = @record.block_slots.select { |a| a.position == position.to_i }.first
        if block.save
          # TODO: this is feeling a little brittle
          # TODO: fix a crash when deleting all blocks
          if block_slot.present?
            block_slot.update(block_id: block.id, updated_at: Time.now)
          end
        else
          respond_to do |format|
            format.html { render :edit, notice: "Unable to update #{block.class.name.titleize}." }
          end
        end
      end
    end

    def blockable_record_is_valid?
      @record&.valid? && @blocks&.values&.collect { |b| b.valid? }.all?
    end

    # TODO: DF 08/06/17 - this should be handled in a before_action so that this method doesn't need to be
    #                     included all over in the generated blockable controller templates.
    # TODO: Split up this method and move into model?
    def parse_block_attributes(record, options = {})
      @record ||= record
      @blocks = {}
      @blocks_updated = false

      record_type = options.fetch :record_type

      params[record_type][:block_slots_attributes] && params[record_type][:block_slots_attributes].each_pair do |index, block_params|
        block_type = block_params['block_type']
        block_constant = block_type.constantize
        block_fields = block_params['block_fields']
        position = block_params['position']
        block_id = params[record_type][:block_slots_attributes][index][:block_id]

        next if block_fields.nil?

        if block_id.present?
          block = block_constant.find block_id
          existing_attributes = HashWithIndifferentAccess.new
          block.permitted_params.each { |a| existing_attributes[a] = block[a] }
        else
          block = block_type.constantize.new
        end

        block_attributes = block_fields.permit block.permitted_params

        # TODO: not sure if a more precise diff between hashes is necessary
        if block.new_record? || (existing_attributes.to_a - block_attributes.as_json.to_a).present?
          block.assign_attributes block_attributes
          @blocks[position] = block
          @blocks_updated = true
        end

        params[record_type][:block_slots_attributes][index].delete :block_fields
      end

      if @blocks_updated
        @record.updated_at = Time.now
      end
    end

end
