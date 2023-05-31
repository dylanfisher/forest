class Forest::Video
  attr_accessor :video_data, :status, :files

  def initialize(video_data)
    @video_data = video_data
    @status = video_data.dig('detail', 'status')
    parse_files
  end

  def high_res
    files.last
  end

  def low_res
    files.first
  end

  private

  # Files are ordered ascending by bitrate, which means low quality files are first, and high quality files are last
  def parse_files
    @files ||= video_data.dig('detail', 'outputGroupDetails').collect do |file_group|
      file_group['outputDetails'].collect do |file_data|
        Forest::Video::File.new(file_data)
      end
    end.flatten.sort_by(&:bitrate)
  end
end
