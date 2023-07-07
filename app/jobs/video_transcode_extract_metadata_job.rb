class VideoTranscodeExtractMetadataJob < ApplicationJob
  LAMBDA_FUNCTION_NAME = 'ffprobe'

  def perform(media_item_id:, object_path:)
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

    media_item = MediaItem.find(media_item_id)

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
end
