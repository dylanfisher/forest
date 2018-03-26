class BlockRecordPolicy < ApplicationPolicy
  def show?
    if record.respond_to?(:statusable?)
      record.published? || edit?
    else
      true
    end
  end

  def index?
    true
  end
end
