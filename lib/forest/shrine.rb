require 'shrine'
require 'shrine/storage/s3'
# require "shrine/storage/file_system"

Forest.config[:keep_files] = ((Rails.env.development? && ENV['FOREST_SHRINE_KEEP_FILES'] != 'false') || ENV['FOREST_SHRINE_KEEP_FILES'] == 'true')

s3_options = Rails.application.credentials.s3

if s3_options
  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: 'cache', **s3_options),
    store: Shrine::Storage::S3.new(prefix: 'media', **s3_options),
  }
end

Shrine.plugin :activerecord           # Load Active Record integration
Shrine.plugin :add_metadata
Shrine.plugin :cached_attachment_data # For retaining cached file on form redisplays
Shrine.plugin :determine_mime_type, analyzer: -> (io, analyzers) do
  mime_type = analyzers[:marcel].call(io)
  mime_type = analyzers[:fastimage].call(io) if mime_type == 'image/svg'
  mime_type
end
Shrine.plugin :infer_extension
Shrine.plugin :instrumentation if (Rails.env.development? || Rails.application.config.log_level == :debug)
Shrine.plugin :keep_files if Forest.config[:keep_files]
Shrine.plugin :pretty_location
Shrine.plugin :refresh_metadata
Shrine.plugin :remote_url, max_size: 40*1024*1024 # ~40mb
Shrine.plugin :restore_cached_data    # Refresh metadata for cached files
Shrine.plugin :type_predicates
Shrine.plugin :uppy_s3_multipart      # Enable S3 multipart upload for Uppy https://github.com/janko/uppy-s3_multipart
Shrine.plugin :url_options, store: { host: Rails.application.credentials.asset_host, public: true } if Rails.application.credentials.asset_host.present?
