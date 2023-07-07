class FileUploader < Shrine
  plugin :backgrounding
  plugin :derivatives
  plugin :default_url
  plugin :store_dimensions
  plugin :upload_options, store: -> (file, options) do
    record = options[:record]
    file_name = [record.title, options[:derivative]].reject(&:blank?).join('-') + record.attachment_data.dig('metadata', 'filename').to_s

    {
      cache_control: 'public, max-age=31536000',
      content_disposition: ContentDisposition.inline(file_name)
    }
  end

  # The Cloudfront URL generated by the serverless image handler
  SERVERLESS_IMAGE_HOST = Rails.application.credentials.image_handler_host
  # https://shrinerb.com/docs/plugins/remote_url#downloader
  DOWNLOADER_OPTIONS = {
    read_timeout: 120,
    open_timeout: 120
  }
  IMAGE_DERIVATIVES = {
    thumb: Forest.image_derivative_thumb_options,
    small: Forest.image_derivative_small_options,
    medium: Forest.image_derivative_medium_options,
    large: Forest.image_derivative_large_options
  }

  # Active Record - Overriding callbacks
  # https://shrinerb.com/docs/plugins/activerecord#overriding-callbacks
  class Attacher
    private

    def activerecord_after_save
      super

      if record.supports_derivatives? && derivatives.blank?
        IMAGE_DERIVATIVES.each_key do |derivative_name|
          AttachmentDerivativeJob.perform_later(self.class.name, self.record.class.name, self.record.id, self.name, self.file_data, derivative_name)
        end
      end

      # TODO: don't reprocess if video is already present, but do reprocess if video has changed
      if record.video?
        VideoTranscodeEnqueueJob.set(wait: rand(1..30).seconds).perform_later(self.record.id)
      end
    end
  end

  # Fall back to the original file URL when a derivative is missing
  # https://shrinerb.com/docs/processing#url-fallbacks
  Attacher.default_url do |derivative: nil, **|
    file&.url if derivative
  end

  # The derivatives plugin allows storing processed files ("derivatives") alongside the main attached file
  # https://shrinerb.com/docs/plugins/derivatives
  Attacher.derivatives do |original|
    if record.supports_derivatives?
      {}
    else
      process_derivatives(:file, original)
    end
  end

  Attacher.derivatives :image do |original, name:|
    def serverless_image_request(edits = {})
      request_path = Base64.strict_encode64({
        bucket: Shrine.storages[:store].bucket.name,
        key: [Shrine.storages[:store].prefix, record.attachment.id].reject(&:blank?).join('/'), # The aws object key of the original image in the `store` S3 bucket
        edits: edits
      }.to_json).chomp
      "#{SERVERLESS_IMAGE_HOST}/#{request_path}"
    end

    edits = IMAGE_DERIVATIVES.fetch(name)
    edits[:jpeg][:force] = !record.try(:retain_source)

    { name => Shrine.remote_url( serverless_image_request(edits) ) }
  end

  Attacher.derivatives :file do |original|
    {}
  end

  Attacher.destroy_block do
    record.destroy_video_list!
    AttachmentDestroyJob.perform_later(self.class.name, data)
  end
end
