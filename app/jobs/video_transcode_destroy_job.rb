class VideoTranscodeDestroyJob < ApplicationJob
  def perform(video_data)
    video = Forest::Video.new(video_data)

    # media_item_id = media_item_path.match(/mediaitem\/(\d*)\/attachment\//)[1].to_i
    # prefix = "#{Shrine.storages[:store].prefix}/mediaitem/#{media_item_id}/attachment/transcoded/"

    # response = client.list_objects({
    #   bucket: Forest.config[:aws_bucket],
    #   prefix: prefix
    # })

    # response.contents
    # binding.pry
  end

  private

  def client
    @client ||= Aws::S3::Client.new
  end
end
