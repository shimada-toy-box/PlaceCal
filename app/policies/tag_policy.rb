# frozen_string_literal: true

class TagPolicy < ApplicationPolicy
  def index?
    user.root? || user.tag_admin?
  end

  def new?
    user.root?
  end

  def create?
    user.root?
  end

  def edit?
    user.root? || user.tag_admin?
  end

  def update?
    user.root?
  end

  def destroy?
    user.root?
  end

  def permitted_attributes
    if user.root?
      %i[name slug description users edit_permission partner_ids]
    else
      %i[partner_ids]
    end
  end

  def disabled_fields
    if user.root?
      %i[partner_ids]
    else
      %i[name slug description users edit_permission partner_ids]
    end
  end

  class Scope < Scope
    def resolve
      if user.root?
        scope.all
      else
        user.tags
      end
    end
  end
end
