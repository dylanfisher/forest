class DashboardPolicy < Struct.new(:user, :dashboard)
  def index?
    admin? || editor? || contributor?
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
