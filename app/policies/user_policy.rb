# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  attr_reader :current_user, :scope

  def initialize(user, record)
    @user = user
    @record = record
  end

  def profile?
    user.id == record.id
  end

  def update_profile?
    profile?
  end

  def index?
    user.root? || user.neighbourhood_admin?
  end

  def create?
    index?
  end

  def new?
    index?
  end

  def update?
    index?
  end

  def edit?
    index?
  end

  def destroy?
    user.root?
  end

  def permitted_attributes
    attrs = %i[
      first_name
      last_name
      email
      phone
      avatar
      partner_ids
    ]
    root_attrs = %i[
      role
      tag_ids
      neighbourhood_ids
      facebook_app_id
      facebook_app_secret
    ]

    attrs + root_attrs if user.root?

    attrs if user.neighbourhood_admin?

    []
  end

  # Fields that should be seen, but disabled
  def disabled_attributes
    disabled_attrs = %i[
      first_name
      last_name
      email
      phone
      avatar
      role
      tag_ids
      neighbourhood_ids
    ]

    [] if user.root?

    disabled_attrs
  end
end
