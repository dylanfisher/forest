module BlockableControllerConcerns
  extend ActiveSupport::Concern

  included do
    before_action :set_block_types, only: [:edit, :new, :create]

    has_scope :by_status
  end

  private

    def set_block_types
      @block_types = BlockType.all
    end

    def save_page(record, options = {})
      @record ||= record
      @record.save
      save_blocks @record, **options # bad pattern?
      @record.set_block_record_cache! # bad pattern?
    end

    def save_blocks(record, options = {})
      return unless @blocks.present?
      @record ||= record
      @blocks.delete_if { |k, v| v.blank? }.each_pair do |position, block|
        if block.save
          # TODO: this is feeling a little brittle
          @record.page_slots.select { |a| a.position == position.to_i }.first.update_column :block_id, block.id
        else
          format.html { render :edit, notice: "Unable to update #{block.class.name.titleize}." }
        end
      end
    end

    # TODO: Split up this method and move into model?
    def parse_block_attributes(record, options = {})
      @record ||= record
      @blocks = {}
      @blocks_updated = false

      record_type = options.fetch :record_type

      params[record_type][:page_slots_attributes] && params[record_type][:page_slots_attributes].each_pair do |index, block_params|
        block_type = block_params['block_type']
        block_constant = block_type.constantize
        block_fields = block_params['block_fields']
        position = block_params['position']
        block_id = params[record_type][:page_slots_attributes][index][:block_id]

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
          block.assign_attributes block_fields.permit(block.permitted_params)
          @blocks[position] = block
          @blocks_updated = true
        end

        params[record_type][:page_slots_attributes][index].delete :block_fields
      end

      if @blocks_updated
        @record.updated_at = Time.now
      end
    end

end
