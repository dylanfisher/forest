class VideoTranscodeExtractMetadataJob < ApplicationJob
  LAMBDA_FUNCTION_NAME = 'ffprobe'
  # https://mattboldt.com/updating-s3-object-metadata-in-ruby/
  COPY_TO_OPTIONS = [:multipart_copy, :content_length, :copy_source_client, :copy_source_region, :acl, :cache_control, :content_disposition,
    :content_encoding, :content_language, :content_type, :copy_source_if_match, :copy_source_if_modified_since, :copy_source_if_none_match,
    :copy_source_if_unmodified_since, :expires, :grant_full_control, :grant_read, :grant_read_acp, :grant_write_acp, :metadata, :metadata_directive,
    :tagging_directive, :server_side_encryption, :storage_class, :website_redirect_location, :sse_customer_algorithm, :sse_customer_key,
    :sse_customer_key_md5, :ssekms_key_id, :copy_source_sse_customer_algorithm, :copy_source_sse_customer_key, :copy_source_sse_customer_key_md5,
    :request_payer, :tagging, :use_accelerate_endpoint]

  def perform(media_item_id:, object_path:)
    media_item = MediaItem.find(media_item_id)

    # Add proper cache control metadata to the object
    filename_from_object_path = object_path.split('/').last
    s3_object = s3_bucket.object(object_path)
    options = {}
    existing_options = s3_object.data.to_h.slice(*COPY_TO_OPTIONS)
    options.merge!(existing_options)
    options.merge!({
      cache_control: 'public, max-age=31536000',
      metadata_directive: 'REPLACE'
    })

    # multipart_copy is necessary if the object is 5GB+
    if s3_object.size >= 5_000_000_000
      options.merge!({ multipart_copy: true })
    else
      # Only used if multipart_copy is true
      options.delete(:content_length)
    end

    s3_object.copy_to("#{Forest.config[:aws_bucket]}/#{object_path}", options)

    # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Lambda/Client.html#invoke-instance_method
    response = lambda_client.invoke({
      function_name: LAMBDA_FUNCTION_NAME,
      invocation_type: 'RequestResponse', # Invoke the function synchronously (the default)
      payload: {
        region: Forest.config[:aws_region],
        bucket: Forest.config[:aws_bucket],
        object_path: object_path
      }.to_json
    })

    # If response is not equal to a 200, log an error
    if (response.status_code.to_s =~ /2\d{2}/).nil?
      Rails.logger.error { '[Forest][Error] VideoTranscodeExtractMetadataJob failed to invoke lambda client.' }
      return
    end

    response_json = JSON.parse(response.payload.string)
    response_body = response_json['body']

    media_item.reload

    # Update media item immediately to avoid race conditions when multiple jobs are called on the same media item
    if media_item.video_data.class != Hash
      media_item.update_columns(video_data: {})
      media_item.reload
    end

    if media_item.video_data['ffprobe'].class != Hash
      media_item.video_data.merge!('ffprobe' => {})
      media_item.update_columns(video_data: media_item.video_data)
      media_item.reload
    end
    media_item.video_data['ffprobe'][object_path] = response_body

    media_item.save if media_item.changed?
  end

  private

  def lambda_client
    @lambda_client ||= Aws::Lambda::Client.new({
      region: Forest.config[:aws_region],
      credentials: Aws::Credentials.new(Aws.config[:credentials].access_key_id, Aws.config[:credentials].secret_access_key)
    })
  end

  def s3_bucket
    @s3_bucket ||= Aws::S3::Bucket.new(Forest.config[:aws_bucket])
  end
end
