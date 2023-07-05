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
        region: Forest.config[:aws_region],
        bucket: Forest.config[:aws_bucket],
        object_path: object_path
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
      region: Forest.config[:aws_region],
      credentials: Aws::Credentials.new(Aws.config[:credentials].access_key_id, Aws.config[:credentials].secret_access_key)
    })
  end
end
