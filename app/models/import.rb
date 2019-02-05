require 'csv'

class Import
  attr_reader :klass, :file

  def initialize(klass, file)
    @klass = klass
    @file = file

    validate_import

    # TODO: initialize import job instead of doing import here
    perform!
  end

  def perform!
    # TODO: this creates a new object per CSV row. It may be worth optimizing further to use
    # something like this approach to do only a single insert.
    # https://gist.github.com/jackrg/76ade1724bd816292e4e
    CSV.foreach(file.tempfile,
                headers: true,
                encoding:'iso-8859-1:utf-8',
                skip_blanks: true,
                skip_lines: /^(?:,\s*)+$/,
                header_converters: -> (f) { f.strip },
                converters: -> (f) { f ? f.strip : nil } ) do |row|
      attrs = row.to_h.compact
      klass.find_or_create_by!(attrs)
    end
  end

  private

    def validate_import
      unless file.content_type == 'text/csv'
        raise "Import must be a .csv file."
      end

      unless klass.present?
        raise "A valid model must be supplied to the import."
      end
    end
end
