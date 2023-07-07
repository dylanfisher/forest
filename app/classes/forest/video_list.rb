class Forest::VideoList
  attr_accessor :video_data, :status, :videos, :jobs

  delegate_missing_to :videos

  def initialize(video_data)
    @video_data = video_data
    @status = video_data.try(:[], 'status')
    parse_job_outputs
    parse_videos
  end

  def low_res
    # TODO: get low res instead of just the first video?
    videos.first
  end

  def high_res
    videos.last
  end

  private

  # Jobs are ordered ascending by bitrate, which means low quality jobs are first, and high quality jobs are last.
  # Sometimes the original source file may end up having the lowest bitrate.
  def parse_job_outputs
    return @jobs = [] if video_data&.dig('job', 'settings', 'output_groups').blank?

    @jobs ||= video_data['job']['settings']['output_groups'][0]['outputs']
  end

  def file_metadata
    @file_metadata ||= begin
      return @file_metadata = [] if video_data&.dig('ffprobe').blank?

      video_data['ffprobe'].collect do |k, v|
        {
          file_path: k,
          metadata: v
        }
      end.sort_by do |data_set|
        data_set[:metadata]['streams'].find { |s| s['codec_type'] == 'video' }['bit_rate'].to_i
      end
    end
  end

  def parse_videos
    @videos ||= begin
      return @videos = [] if file_metadata.blank?

      file_metadata.collect { |f| Forest::Video.new(f) }
    end
  end
end
