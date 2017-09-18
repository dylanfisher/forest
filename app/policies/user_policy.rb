class UserPolicy < ApplicationPolicy
  def show?
    update?
  end

  def update?
    admin? || @record == @user
  end

  def edit?
    update?
  end

  def reset_password?
    update?
  end
end
