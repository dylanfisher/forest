class VideoTranscodeEnqueueJob < ApplicationJob
  LAMBDA_FUNCTION_NAME = 'TranscodeVideo'

  def perform(media_item_id)
    media_item = MediaItem.find(media_item_id)
    object_path = "#{Shrine.storages[:store].prefix}/#{media_item.attachment_data['id']}"

    # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Lambda/Client.html#invoke-instance_method
    response = lambda_client.invoke({
      function_name: LAMBDA_FUNCTION_NAME,
      invocation_type: 'RequestResponse', # Invoke the function synchronously (the default)
      payload: {
        region: aws_region,
        object_path: object_path,
        bucket: Rails.application.credentials.s3.bucket
      }.to_json
    })

    # If response is not equal to a 200, log an error
    if (response.status_code.to_s =~ /2\d{2}/).nil?
      Rails.logger.error { '[Forest][Error] VideoTranscodeEnqueueJob failed to invoke lambda client.' }
      return
    end

    response_json = JSON.parse(response.payload.string)
    response_body = JSON.parse(response_json['body'])
    job_id = response_body['createJobResponse']['Job']['Id']

    VideoTranscodePollJob.perform_later(media_item_id: media_item_id, job_id: job_id)
  end

  private

  def lambda_client
    @lambda_client ||= Aws::Lambda::Client.new({
      region: aws_region,
      credentials: Aws::Credentials.new(s3_access_key_id, s3_secret_access_key)
    })
  end

  def s3_access_key_id
    @s3_access_key_id ||= ENV['AWS_ACCESS_KEY_ID'].presence || Rails.application.credentials&.dig(:s3, :access_key_id)
  end

  def s3_secret_access_key
    @s3_secret_access_key ||= ENV['AWS_SECRET_KEY_ID'].presence || Rails.application.credentials&.dig(:s3, :secret_access_key)
  end

  def aws_region
    @aws_region ||= ENV['AWS_REGION'].presence || Rails.application.credentials&.dig(:s3, :region)
  end

  def s3_bucket
    @s3_bucket ||= s3.bucket(s3_bucket_name)
  end
end
