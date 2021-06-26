require 'shrine'
require 'shrine/storage/s3'
# require "shrine/storage/file_system"

s3_options = Rails.application.credentials.s3

if s3_options
  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: 'cache', public: true, **s3_options),
    store: Shrine::Storage::S3.new(prefix: 'media', public: true, **s3_options),
  }
end

Shrine.plugin :activerecord           # Load Active Record integration
Shrine.plugin :add_metadata
Shrine.plugin :cached_attachment_data # For retaining cached file on form redisplays
Shrine.plugin :determine_mime_type
Shrine.plugin :infer_extension
Shrine.plugin :instrumentation if (Rails.env.development? || Rails.application.config.log_level == :debug)
Shrine.plugin :pretty_location
Shrine.plugin :refresh_metadata
Shrine.plugin :remote_url, max_size: 40*1024*1024 # ~40mb
Shrine.plugin :restore_cached_data    # Refresh metadata for cached files
Shrine.plugin :type_predicates
Shrine.plugin :uppy_s3_multipart      # Enable S3 multipart upload for Uppy https://github.com/janko/uppy-s3_multipart
Shrine.plugin :url_options, store: { host: Rails.application.credentials.asset_host } if Rails.application.credentials.asset_host.present?
