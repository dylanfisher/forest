require 'shrine'
require 'shrine/storage/s3'

s3_options = Rails.application.credentials.s3

Shrine.storages = {
  cache: Shrine::Storage::S3.new(prefix: 'cache', public: true, **s3_options),
  store: Shrine::Storage::S3.new(prefix: 'media', public: true, **s3_options),
}

Shrine.plugin :activerecord           # load Active Record integration
Shrine.plugin :cached_attachment_data # for retaining cached file on form redisplays
Shrine.plugin :restore_cached_data    # refresh metadata for cached files
Shrine.plugin :uppy_s3_multipart      # enable S3 multipart upload for Uppy https://github.com/janko/uppy-s3_multipart
Shrine.plugin :url_options, store: { host: Rails.application.credentials.asset_host } if Rails.application.credentials.asset_host.present?
