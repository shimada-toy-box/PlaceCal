# frozen_string_literal: true

require 'test_helper'

class PartnerTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @new_partner = build(:partner, address: create(:address), accessed_by_user: @user)
  end

  test 'updates user roles when saved' do
    @new_partner.users << @user
    @new_partner.save
    assert @user.partner_admin?
  end

  test 'validate name length' do
    @new_partner.update(name: '1234')

    assert error_map = @new_partner.errors.where(:name, :too_short).first
    assert_equal 'must be at least 5 characters long', error_map.options[:message]
    assert_equal 1, @new_partner.errors.attribute_names.length
  end

  test 'validate uniqueness' do
    other_partner = Partner.create(name: 'Alpha Name', address: @new_partner.address, accessed_by_user: @user)

    # Name must be unique
    @new_partner.update(name: other_partner.name)
    assert_equal ['has already been taken'], @new_partner.errors[:name]
  end

  test 'validate no summary or description' do
    @new_partner.update(name: 'Test Partner', summary: '', description: '')
    assert @new_partner.errors.empty?
  end

  test 'validate summary without description' do
    @new_partner.update(name: 'Test Partner', summary: 'This is a test partner used for testing :)', description: '')
    assert @new_partner.errors.empty?, 'Should be able to submit a summary'
  end

  test 'validate description without summary' do
    @new_partner.update(
      name: 'Test Partner', 
      description: 'This is a test partner used for testing :)',
      summary: ''
    )
    assert_equal ['cannot have a description without a summary'],
                 @new_partner.errors[:summary],
                 'Should not be able to have a description without summary'
  end

  test 'validate description and summary' do

    @new_partner.update(name: 'Test Partner',
                   summary: 'This is a test summary wheee :)',
                   description: 'This is a test new_partner used for testing :)')
    assert @new_partner.errors.empty?, 'Should be able to submit a summary and description'
  end

  test 'validate summary length' do
    # We can submit a 200 character summary
    @new_partner.update(name: 'Test Partner', summary: ''.ljust(200, 'a'))
    assert @new_partner.errors.empty?, '200 character summary should be valid'

    # But not a 201 character summary
    @new_partner.update(name: 'Test Partner', summary: ''.ljust(201, 'a'))
    assert @new_partner.errors.key?(:summary), 'maximum length is 200 characters'
  end

  test 'validate url' do
    # Url must be valid
    @new_partner.update(url: 'htp://bad-domain.co')
    assert_equal ['is invalid'], @new_partner.errors[:url], 'Partner must have a valid url'
    @new_partner.update(url: 'https://good-domain.com')
    refute @new_partner.errors.key?(:url), 'Valid URL not saved'
  end

  test 'validate twitter' do
    # Twitter must be valid
    @new_partner.update(twitter_handle: '@asdf')
    refute @new_partner.errors.key?(:twitter_handle), 'Valid twitter not saved'
    @new_partner.update(twitter_handle: 'asdf')
    refute @new_partner.errors.key?(:twitter_handle), 'Valid twitter not saved'
    @new_partner.update(twitter_handle: 'https://twitter.com/asdf')
    assert @new_partner.errors.key?(:twitter_handle), 'Should be account name not full URL'
    @new_partner.update(twitter_handle: 'asd£$%dsa')
    assert @new_partner.errors.key?(:twitter_handle), 'Invalid Twitter account name saved'
  end

  test 'validate facebook' do
    # Facebook must be valid
    @new_partner.update(facebook_link: 'https://facebook.com/group-name')
    assert @new_partner.errors.key?(:facebook_link), 'Should be page name not full URL'
    @new_partner.update(facebook_link: 'Group-Name')
    assert @new_partner.errors.key?(:facebook_link), 'invalid Facebook page name saved'
    @new_partner.update(facebook_link: 'GroupName')
    refute @new_partner.errors.key?(:facebook_link), 'Valid page name not saved'
  end
end


class PartnerServiceAreaTest < ActiveSupport::TestCase
  setup do
    @neighbourhood = neighbourhoods(:one)
    @user = create(:user)
    @user.neighbourhoods << @neighbourhood
    @partner = build(:partner, address: nil, accessed_by_user: @user)
  end

  test 'is valid when empty' do
    # give partner an address the user administrates
    @partner.address = create(:address, neighbourhood: @neighbourhood)
    @partner.save!

    assert @partner.valid?, 'Partner (without service_area) is not valid'
  end

  test 'is valid when set, can be accessed' do
    model = build(:ashton_service_area_partner)
    model.save!
    assert model.valid?

    service_areas = model.service_areas
    assert_equal 1, service_areas.count
  end

  test 'can be assigned' do
    @partner.accessed_by_user = @user
    @partner.service_area_neighbourhoods << @neighbourhood
    @partner.save!

    assert @partner.valid?, 'Partner (with service_area) is not valid'

    neighbourhood_count = @partner.service_area_neighbourhoods.count
    assert_equal 1, neighbourhood_count, 'count neighbourhoods'
  end

  test 'must be unique' do
    @partner.address = create(:address, neighbourhood: @neighbourhood)
    @partner.save!

    assert_raises ActiveRecord::RecordInvalid do 
      @partner.service_areas.create!(neighbourhood: @neighbourhood)
      @partner.service_areas.create!(neighbourhood: @neighbourhood)
    end
    # need to also test this with regards to model creation from the web front-end
  end

  test 'can be read when present' do
    @partner.address = create(:address, neighbourhood: @neighbourhood)
    @partner.save!

    other_neighbourhood = create(:ashton_neighbourhood)
    @partner.service_areas.create! neighbourhood: @neighbourhood
    @partner.service_areas.create! neighbourhood: other_neighbourhood

    neighbourhoods = @partner.service_area_neighbourhoods.order('neighbourhoods.name').all
    assert neighbourhoods.count == 2, 'Failed to count neighbourhoods'

    n1 = neighbourhoods[0]
    assert_equal 'Ashton Hurst', n1.name

    n2 = neighbourhoods[1]
    assert_equal 'Hulme', n2.name
  end

  test 'must be within users neighbourhoods' do
    @partner.service_areas.build neighbourhood: create(:moss_side_neighbourhood)
    @partner.validate

    assert @partner.valid? == false, 'Partner should not be valid'
  end
end

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

  test "is invalid if both service area and address not present" do
    
    @new_partner.validate

    assert @new_partner.valid? == false, 'Partner should be invalid'
    
    base_errors = @new_partner.errors[:base]
    assert base_errors.length > 0
  end

  test 'is valid with service_area set' do
    @new_partner.service_areas.build neighbourhood: @neighbourhood
    @new_partner.validate

    assert @new_partner.valid? == true, 'Partner should be valid'
  end

  test 'is valid with address set' do
    address = build(:address, neighbourhood: @neighbourhood)

    @new_partner.address = address
    @new_partner.save!

    assert @new_partner.valid? == true, 'Partner should be valid'
  end

  test 'is valid with both service_area and address set' do
    address = build(:address)

    @new_partner.address = address
    @new_partner.service_areas.build neighbourhood: @neighbourhood
    @new_partner.validate

    assert @new_partner.valid? == true, 'Partner should valid'
  end
end

class PartnerAddressOrServiceAreaPermissionsTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @user_neighbourhood =  neighbourhoods(:one)
    
    @user.neighbourhoods << @user_neighbourhood

    @new_partner = build(
      :partner, 
      address: nil,
      accessed_by_user: @user
    )
  end

  test "valid if address is in user ward" do
    @new_partner.address = create(:address, neighbourhood: @user_neighbourhood)
    @new_partner.save!

    assert @new_partner.valid?
  end

  test "verify: with service area in user neighbourhoods" do
    @new_partner.service_area_neighbourhoods << @user_neighbourhood
    @new_partner.save!

    assert @new_partner.valid?
  end

  test "verify: with service area contained within users neighbourhood subtrees" do
    child_neighbourhood = create(:neighbourhood)
    parent_neighbourhood = child_neighbourhood.parent

    @user.neighbourhoods << parent_neighbourhood

    @new_partner.service_area_neighbourhoods << child_neighbourhood
    @new_partner.save!

    assert @new_partner.valid?
  end

  test "with a service area not in user's ward set" do
    other_neighbourhood = neighbourhoods(:two)

    @new_partner.service_area_neighbourhoods << @user_neighbourhood
    @new_partner.service_area_neighbourhoods << other_neighbourhood

    assert @new_partner.valid? == false, 'Users cannot create service areas outside of their neighbourhoods'
  end
end


