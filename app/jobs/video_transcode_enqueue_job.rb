class VideoTranscodeEnqueueJob < ApplicationJob
  LAMBDA_FUNCTION_NAME = 'TranscodeVideo'
  ERROR_TOO_MANY_REQUESTS = 'too many requests'

  def perform(media_item_id, retry_count: 0)
    retry_count += 1
    media_item = MediaItem.find(media_item_id)
    object_path = "#{Shrine.storages[:store].prefix}/#{media_item.attachment_data['id']}"

    if media_item.video_data.class != Hash
      media_item.update_columns(video_data: { 'status' => Forest::VideoList::TRANSCODE_STATUS_ENQUEUED })
    else
      media_item.update_columns(video_data: media_item.video_data.merge('status' => Forest::VideoList::TRANSCODE_STATUS_ENQUEUED))
    end

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

    if retry_count > 20
      Rails.logger.error { "[Forest][Error] VideoTranscodeEnqueueJob retry count exceeded. Video transcode failed to enqueue." }
      return
    elsif response_json['errorMessage'].to_s.downcase == ERROR_TOO_MANY_REQUESTS
      VideoTranscodeEnqueueJob.set(wait: rand(30..90).seconds).perform_later(media_item_id, retry_count: retry_count)
      return
    elsif response_json['body'].blank?
      if retry_count < 6
        VideoTranscodeEnqueueJob.set(wait: rand(30..90).seconds).perform_later(media_item_id, retry_count: retry_count)
      else
        Rails.logger.error { "[Forest][Error] VideoTranscodeEnqueueJob lambda response was blank.\nStatus Code: #{response.status_code}\n#{response_json}" }
      end
      return
    end

    response_body = JSON.parse(response_json['body'])
    job_id = response_body['createJobResponse']['Job']['Id']

    VideoTranscodePollJob.set(wait: rand(60..90).seconds).perform_later(media_item_id: media_item_id, job_id: job_id)
  end

  private

  def lambda_client
    @lambda_client ||= Aws::Lambda::Client.new({
      region: Forest.config[:aws_region],
      credentials: Aws::Credentials.new(Aws.config[:credentials].access_key_id, Aws.config[:credentials].secret_access_key)
    })
  end
end
