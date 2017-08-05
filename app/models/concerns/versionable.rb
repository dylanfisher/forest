module Versionable
  extend ActiveSupport::Concern

  included do
    has_paper_trail meta: { status: :status_id }

    def current_published_version
      if self.published?
        self
      elsif self.respond_to?(:versions)
        # self.versions.reorder(created_at: :desc, id: :desc).where(status: Page.statuses[:published]).first.try(:reify)
        self.versions.reorder(created_at: :desc, id: :desc).where_object(status: Page.statuses[:published]).first.try(:reify)
      end
    end

    def versionable?
      true
    end

    private

      def status_id
        # TODO: this is saving the previous version ID, not the current id....
        self.class.statuses[status]
      end
  end
end
