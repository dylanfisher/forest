class AttachmentDerivativeJob < ApplicationJob
  # https://shrinerb.com/docs/plugins/backgrounding

  def perform(attacher_class, record_class, record_id, name, file_data, derivative_name)
    attacher_class = Object.const_get(attacher_class)
    record         = Object.const_get(record_class).find(record_id) # if using Active Record

    attacher = attacher_class.retrieve(model: record, name: name, file: file_data)
    attacher.create_derivatives(:image, name: derivative_name) # calls derivatives processor

    attacher.atomic_persist do |reloaded_attacher|
      # make sure we don't override derivatives created in other jobs
      attacher.merge_derivatives(reloaded_attacher.derivatives)
    end
  rescue Shrine::AttachmentChanged, ActiveRecord::RecordNotFound
    attacher.derivatives[derivative_name].delete # delete now orphaned derivative
  end
end
