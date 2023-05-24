class VideoTranscodeEnqueueJob < ApplicationJob
  LAMBDA_FUNCTION_NAME = 'transcodeVideoTest2'

  def perform(media_item_id)
    media_item = MediaItem.find(media_item_id)
    object_path = "#{Shrine.storages[:store].prefix}/#{media_item.attachment_data['id']}"

    # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Lambda/Client.html#invoke-instance_method
    response = lambda_client.invoke({
      function_name: LAMBDA_FUNCTION_NAME,
      invocation_type: 'Event', # Invoke the function asynchronously
      payload: {
        object_path: object_path
      }.to_json
    })

    # TODO: failure state if response is not 200
    # TODO: MediaEncode lambda function callback needs to send back a
    #       webhook to our app.
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
end
