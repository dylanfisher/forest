module Versionable
  extend ActiveSupport::Concern

  included do
    has_paper_trail meta: {
      block_slots: :set_versionable_block_slots
    }

    def current_published_version
      if self.published?
        self
      elsif self.respond_to?(:versions)
        # self.versions.reorder(created_at: :desc, id: :desc).where(status: Page.statuses[:published]).first.try(:reify)
        self.versions.reorder(created_at: :desc, id: :desc).where_object(status: Statusable::PUBLISHED).first.try(:reify)
      end
    end

    def versionable?
      true
    end

    private

      def set_versionable_block_slots
        self.block_slots.as_json
      end
  end
end
