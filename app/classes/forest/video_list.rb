class Forest::VideoList
  attr_accessor :video_data, :status, :files, :jobs

  def initialize(video_data)
    @video_data = video_data
    @status = video_data['status']
    parse_job_outputs
    parse_files
  end

  def low_res
    files.first
  end

  def high_res
    files.last
  end

  private

  # Jobs are ordered ascending by bitrate, which means low quality jobs are first, and high quality jobs are last
  def parse_job_outputs
    return @jobs = [] if video_data.dig('job', 'settings', 'output_groups').blank?

    @jobs ||= video_data['job']['settings']['output_groups'][0]['outputs'].collect do |file_data|
      Forest::Video.new(file_data)
    end.flatten.sort_by(&:bitrate)
  end

  def parse_files
    @files ||= begin
      return @files = [] if video_data['ffprobe'].blank?

      video_data['ffprobe'].collect do |k, v|
        {
          filename: k,
          metadata: v
        }
      end
    end
  end
end
