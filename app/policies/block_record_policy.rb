class BlockRecordPolicy < ApplicationPolicy
  def show?
    if record.try(:statusable?)
      record.published? || edit?
    else
      true
    end
  end

  def index?
    true
  end
end
