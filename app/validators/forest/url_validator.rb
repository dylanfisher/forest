# Use custom namespaced validators like this:
# validates :url, 'forest/url': true

module Forest
  class UrlValidator < ActiveModel::EachValidator
    def self.compliant_absolute_url?(value)
      uri = URI.parse(value)
      uri.is_a?(URI::HTTP) && !uri.host.blank? && uri.host.include?('.')
    rescue URI::InvalidURIError
      false
    end

    def self.compliant_relative_url?(value)
      uri = URI.parse(value)
      uri.relative? && (uri.path.first == '/' || uri.to_s.first == '#')
    end

    def validate_each(record, attribute, value)
      return false if value.blank?

      if options[:relative]
        unless self.class.compliant_relative_url?(value) || self.class.compliant_absolute_url?(value)
          record.errors.add(attribute, "is not a valid HTTP or relative URL")
        end
      else
        unless self.class.compliant_absolute_url?(value)
          record.errors.add(attribute, "is not a valid URL. Please use the format https://example.org.")
        end
      end
    end
  end
end
