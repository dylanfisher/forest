class Forest::Video
  attr_accessor :file_path, :filename, :duration, :width, :height, :bitrate, :quality, :extension, :url

  SUFFIX_LOW_RES = '_LOW_RES'
  SUFFIX_HIGH_RES = '_HIGH_RES'

  # TODO: finish formatting data from new file structure
  def initialize(file_data)
    @file_path = file_data[:file_path]
    @filename = file_path.split('/').last
    metadata = file_data[:metadata]
    video_stream = metadata['streams'].find { |x| x['codec_type'] == 'video' }
    audio_stream = metadata['streams'].find { |x| x['codec_type'] == 'audio' }
    @duration = video_stream['duration'].to_f
    @width = video_stream['width']
    @height = video_stream['height']
    @bitrate = video_stream['bit_rate'].to_i
    @extension = File.extname(filename)

    if filename.match(/#{SUFFIX_LOW_RES}#{extension}$/)
      @quality = 'LOW_RES'
    elsif filename.match(/#{SUFFIX_HIGH_RES}#{extension}$/)
      @quality = 'HIGH_RES'
    else
      @quality = 'ORIGINAL'
    end

    @url = "#{Rails.application.credentials.dig(:asset_host)}/#{file_path.sub(/s3:\/\/#{Rails.application.credentials.dig(:s3, :bucket)}\//, '')}"
  end
end
