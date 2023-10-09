class VideoTranscodeDestroyJob < ApplicationJob
  def perform(video_data)
    video_list = Forest::VideoList.new(video_data)

    video_list.videos.each do |video|
      key = video.file_path

      # We don't need to delete the source file because the attachment destroy job already does this
      next unless key.split('/').include?('transcoded')

      response = client.delete_object({
        bucket: Forest.config[:aws_bucket],
        key: key
      })
    end
  end

  private

  def client
    @client ||= Aws::S3::Client.new(credentials: Forest.config[:credentials], region: Forest.config[:aws_region])
  end
end
