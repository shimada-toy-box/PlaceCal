# frozen_string_literal: true

require 'test_helper'

class PartnerAddressOrServiceAreaPresenceTest < ActiveSupport::TestCase
  setup do
    @user = create(:root)
    @neighbourhood = neighbourhoods(:one)
    @user.neighbourhoods << @neighbourhood

    @new_partner = Partner.new(
      name: 'Alpha name',
      summary: 'Summary of alpha',
      accessed_by_user: @user
    )
  end

  test 'is invalid if both service area and address not present' do
    @new_partner.validate

    assert_not_predicate(@new_partner, :valid?, 'Partner should be invalid')

    base_errors = @new_partner.errors[:base]
    assert_predicate base_errors.length, :positive?
  end

  test 'is valid with service_area set' do
    @new_partner.service_areas.build neighbourhood: @neighbourhood
    @new_partner.validate

    assert_predicate(@new_partner, :valid?, 'Partner should be valid')
  end

  test 'is valid with address set' do
    address = build(:address, neighbourhood: @neighbourhood)

    @new_partner.address = address
    @new_partner.save!

    assert_predicate(@new_partner, :valid?, 'Partner should be valid')
  end

  test 'is valid with both service_area and address set' do
    address = build(:address)

    @new_partner.address = address
    @new_partner.service_areas.build neighbourhood: @neighbourhood
    @new_partner.validate

    assert_predicate(@new_partner, :valid?, 'Partner should valid')
  end
end
