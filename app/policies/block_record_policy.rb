class BlockRecordPolicy < ApplicationPolicy
  def show?
    record.published? || edit?
  end

  def show_index?
    true
  end

  def versions?
    index?
  end

  def version?
    edit?
  end

  def restore?
    edit?
  end
end
