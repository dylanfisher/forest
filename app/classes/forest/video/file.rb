class Forest::Video::File
  attr_accessor :file_data, :duration, :width, :height, :bitrate, :quality, :file_path, :url

  # TODO: finish formatting data from new file structure
  def initialize(file_data)
    @file_data = file_data
    @duration = file_data['durationInMs']
    @width = file_data['videoDetails']['widthInPx']
    @height = file_data['videoDetails']['heightInPx']
    @bitrate = file_data['videoDetails']['averageBitrate']
    @quality = file_data['videoDetails']['qvbrAvgQuality']
    @file_path = file_data['outputFilePaths'][0]
    @url = "#{Rails.application.credentials.dig(:asset_host)}/#{file_path.sub(/s3:\/\/#{Rails.application.credentials.dig(:s3, :bucket)}\//, '')}"
  end
end
