class MediaItemPolicy < ApplicationPolicy
  def reprocess?
    update?
  end

  def update_multiple?
    destroy?
  end

  def transcode?
    update?
  end
end
