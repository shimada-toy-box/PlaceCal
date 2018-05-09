class SitePolicy < ApplicationPolicy

  def index?
    user.role.present? && user.role.root?
  end

  def new?
    index?
  end

  def create?
    index?
  end

  def edit?
    index?
  end

  def update?
    index?
  end

end
