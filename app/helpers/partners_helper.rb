# frozen_string_literal: true

module PartnersHelper
  def options_for_service_area_neighbourhoods
    # Remove the primary neighbourhood from the list
    @all_neighbourhoods.filter { |e| e.name != '' }
                       .collect { |e| { name: e.contextual_name, id: e.id } }
  end

  def options_for_tags
    policy_scope(Tag).all.order(:name).pluck(:name, :id)
  end

  def partner_service_area_text(partner)
    neighbourhoods = partner.service_area_neighbourhoods.order(:name).all

    if neighbourhoods.length == 1
      neighbourhoods.first.name

    else
      head = neighbourhoods[0..-2]
      tail = neighbourhoods[-1]

      "#{head.map(&:name).join(', ')} and #{tail.name}"
    end
  end
end
