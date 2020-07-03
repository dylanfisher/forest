require 'shrine'
require 'shrine/storage/s3'

s3_options = Rails.application.credentials.s3

Shrine.storages = {
  cache: Shrine::Storage::S3.new(prefix: 'cache', **s3_options),
  store: Shrine::Storage::S3.new(prefix: 'media', **s3_options),
}

Shrine.plugin :activerecord           # load Active Record integration
Shrine.plugin :cached_attachment_data # for retaining cached file on form redisplays
Shrine.plugin :restore_cached_data    # refresh metadata for cached files
Shrine.plugin :presign_endpoint, presign_options: -> (request) {
  # Uppy will send the "filename" and "type" query parameters
  filename = request.params["filename"]
  type     = request.params["type"]

  {
    content_disposition:    ContentDisposition.inline(filename), # set download filename
    content_type:           type,                                # set content type (defaults to "application/octet-stream")
    content_length_range:   0..(10*1024*1024),                   # limit upload size to 10 MB
  }
}
