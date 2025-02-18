# frozen_string_literal: true

require 'test_helper'

class Admin::PartnersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @root = create(:root)
    @citizen = create(:user)

    @address = create(:address)
    @neighbourhood = @address.neighbourhood

    @neighbourhood_admin = create(:user)
    @neighbourhood_admin.neighbourhoods << @neighbourhood

    @partner = create(:partner, address_id: @address.id)

    @partner_admin = create(:user)
    @partner_admin.partners << @partner

    @partner_two = create(:partner)

    host! 'admin.lvh.me'
  end

  # Partner Index
  #
  #   Show every Partner for roots
  #   Show an empty page for citizens
  #   TODO: test for more permutations

  it_allows_access_to_index_for(%i[root]) do
    get admin_partners_url
    assert_response :success
    # Has a button allowing us to add new Partners
    assert_select 'a', 'Add New Partner'
    # Returns one entry in the table
    assert_select 'tbody tr', 2
  end

  it_allows_access_to_index_for(%i[partner_admin]) do
    get admin_partners_url
    assert_response :success
    assert_select 'td', @partner.name
    assert_select 'tbody tr', 1
    # Nothing to show in the table
  end

  it_allows_access_to_index_for(%i[neighbourhood_admin]) do
    get admin_partners_url
    assert_response :success
    # assert_select 'a', 'Edit'
    assert_select 'tbody tr', 2
    # Nothing to show in the table
  end

  it_denies_access_to_index_for(%i[citizen]) do
    get admin_partners_url
    assert_response :success
    # Nothing to show in the table
    assert_select 'tbody tr', 0
  end

  # Show partner
  #
  #   This shouldn't really happen normally.
  #   Redirect to edit page.
  it_allows_access_to_show_for(%i[root neighbourhood_admin partner_admin]) do
    get admin_partner_url(@partner)
    assert_redirected_to edit_admin_partner_url(@partner)
  end

  # New & Create Partner
  #
  #   Allow secretaries to create new Partners
  #   Everyone else, redirect to admin_partners_url

  it_allows_access_to_new_for(%i[root neighbourhood_admin]) do
    get new_admin_partner_url
    assert_response :success
  end

  it_denies_access_to_new_for(%i[partner_admin]) do
    get new_admin_partner_url
    assert_redirected_to admin_partners_url
  end

  it_allows_access_to_create_for(%i[root neighbourhood_admin]) do
    assert_difference('Partner.count') do
      post admin_partners_url,
           params: { partner: { name: 'A new partner',
                                address_attributes: {
                                  street_address: '123 Moss Ln E',
                                  postcode: 'M15 5DD'
                                } } }
    end
  end

  it_denies_access_to_create_for(%i[partner_admin]) do
    assert_difference('Partner.count', 0) do
      post admin_partners_url,
           params: { partner: { name: 'A new partner' } }
    end
  end

  # Edit & Update Partner
  #
  #   Allow roots to edit all places
  #   Everyone else, redirect to admin_partners_url

  it_allows_access_to_edit_for(%i[root neighbourhood_admin partner_admin]) do
    assert_equal @partner.address.neighbourhood_id, @neighbourhood_admin.neighbourhood_ids.last
    get edit_admin_partner_url(@partner)
    assert_response :success
  end

  it_denies_access_to_edit_for(%i[partner_admin]) do
    get edit_admin_partner_url(@partner_two)
    assert_redirected_to admin_partners_url
  end

  it_allows_access_to_update_for(%i[root neighbourhood_admin partner_admin]) do
    patch admin_partner_url(@partner),
          params: { partner: { name: 'Updated partner name' } }
    # Redirect to main partner screen
    assert_redirected_to edit_admin_partner_url(@partner)
  end

  # For partner not assigned or in area
  it_denies_access_to_update_for(%i[partner_admin]) do
    patch admin_partner_url(@partner_two),
          params: { partner: { name: 'Updated partner name' } }
    assert_redirected_to admin_partners_url
  end

  test 'it allows access to update for wardless user' do
    partner = create(:partner)
    user = create(:citizen, partners: [partner])
    access_info = 'This is some accessibility info'

    sign_in user

    patch admin_partner_url(partner),
          params: { partner: { accessibility_info: access_info } }

    assert_redirected_to edit_admin_partner_url(partner)
    assert_equal Partner.find_by(id: partner.id).accessibility_info, access_info
  end

  # Delete Partner
  #
  #   Allow roots to delete all Partners
  #   Everyone else redirect to admin_partners_url

  it_allows_access_to_destroy_for(%i[root neighbourhood_admin]) do
    assert_difference('Partner.count', -1) do
      delete admin_partner_url(@partner)
    end

    assert_redirected_to admin_partners_url
  end

  it_denies_access_to_destroy_for(%i[partner_admin citizen]) do
    assert_difference('Partner.count', 0) do
      delete admin_partner_url(@partner)
    end
  end

  # Setup Partner

  test 'neighbourhood_admin : can access setup' do
    sign_in @neighbourhood_admin

    get setup_admin_partners_url
    assert_response :success
  end

  test 'neighbourhood_admin : can setup new partner in ward' do
    sign_in @neighbourhood_admin

    params = {
      partner: {
        name: 'New Partner',
        address_attributes: {
          street_address: '123 Moss Ln E',
          postcode: 'M15 5DD'
        }
      }
    }

    post setup_admin_partners_url, params: params
    assert_redirected_to new_admin_partner_url(params)
  end

  test 'neighbourhood_admin : cannot setup new partner not in ward' do
    sign_in @neighbourhood_admin

    params = {
      partner: {
        name: 'New Partner',
        address_attributes: {
          street_address: 'Ashton-under-Lyne',
          postcode: 'OL6 8BH'
        }
      }
    }

    post setup_admin_partners_url, params: params

    assert_template :setup
  end
end
