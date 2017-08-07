module Versionable
  extend ActiveSupport::Concern

  included do
    def self.versionable?
      true
    end

    def versionable?
      true
    end
  end
end
