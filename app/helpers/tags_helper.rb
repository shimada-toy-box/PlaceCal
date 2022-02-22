# frozen_string_literal: true

# app/helpers/tags_helper.rb
module TagsHelper
  def options_for_partners
    policy_scope(Partner).all.order(:name).pluck(:name, :id)
  end
end
