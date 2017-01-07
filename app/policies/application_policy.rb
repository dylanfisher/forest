class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    admin? || editor? || contributor?
  end

  def show?
    # scope.where(:id => record.id).exists?
    true
  end

  def create?
    admin?
  end

  def new?
    create?
  end

  def update?
    admin?
  end

  def edit?
    update?
  end

  def destroy?
    admin?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  private

    def admin?
      user.try(:admin?)
    end

    def editor?
      user.try(:in_group?, 'editor')
    end

    def contributor?
      user.try(:in_group?, 'contributor')
    end
end
