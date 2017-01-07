class MediaItemPolicy < ApplicationPolicy
  def update_multiple?
    destroy?
  end
end
