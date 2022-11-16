class Admin::PositionUpdaterController < Admin::ForestController
  def update
    resource = params[:resource].constantize

    authorize resource, :update_positions?

    record_ids_with_position = params[:records].as_json
    record_ids_with_position.transform_keys!(&:to_i)
    record_ids_with_position.transform_values!(&:to_i)
    record_ids = record_ids_with_position.keys

    records_cache = resource.find(record_ids).to_a
    new_record_ids_with_position = []

    position_has_changed = false
    record_ids_with_position.each do |record_id, position|
      record = records_cache.find { |r| r.id == record_id }
      position_has_changed = true if record.position != position
      new_record_ids_with_position << { id: record.id, position: position }
    end

    if position_has_changed
      record_ids_with_position.each do |record_id, position|
        record = records_cache.find { |r| r.id == record_id }
        record.update(position: position)
      end
    end

    render json: new_record_ids_with_position
  end
end
