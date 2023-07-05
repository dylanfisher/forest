class VideoTranscodePollJob < ApplicationJob
  def perform(media_item_id:, job_id:, poll_count: 0)
    media_item = MediaItem.find(media_item_id)

    media_convert_client = Aws::MediaConvert::Client.new({
      endpoint: media_convert_endpoint
    })

    media_convert_response = media_convert_client.get_job({
      id: job_id
    })

    # https://docs.aws.amazon.com/mediaconvert/latest/ug/how-mediaconvert-jobs-progress.html
    # Potential statuses: SUBMITTED, PROGRESSING, COMPLETE, ERROR, CANCELED
    status = media_convert_response.job.status
    media_item.video_data = {} if media_item.video_data.blank?
    media_item.video_data['status'] = status

    if %w(SUBMITTED PROGRESSING).include?(status)
      wait_time = 1.minute
      wait_time = 5.minutes if poll_count > 4
      wait_time = 10.minutes if poll_count > 8
      if poll_count < 15
        VideoTranscodePollJob.set(wait: wait_time).perform_later(media_item_id: media_item_id, job_id: job_id, poll_count: (poll_count + 1))
      else
        media_item.video_data['status'] = 'POLLING_FAILED'
      end
    elsif status == 'COMPLETE'
      media_item.video_data['job'] = deep_compact!(media_convert_response.job.as_json)
      media_item.save if media_item.changed?
      media_item.extract_video_metadata!
    end

    media_item.save if media_item.changed?
  end

  private

  def media_convert_endpoint
    @media_convert_endpoint ||= ENV['AWS_MEDIA_CONVERT_ENDPOINT'].presence || Rails.application.credentials&.dig(:aws_media_convert_endpoint)
  end

  def deep_compact!(hash_or_array)
    p = proc do |*args|
      v = args.last
      v.delete_if(&p) if v.respond_to? :delete_if
      v.nil? || v.respond_to?(:"empty?") && v.empty?
    end

    hash_or_array.delete_if(&p)
  end
end
