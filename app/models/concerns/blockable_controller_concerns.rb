module BlockableControllerConcerns
  extend ActiveSupport::Concern

  included do
    before_action :set_block_kinds, only: [:edit, :new, :create, :update]

    has_scope :by_status
  end

  private

    def set_block_kinds
      @block_kinds = BlockKind.all.by_name
    end
end
