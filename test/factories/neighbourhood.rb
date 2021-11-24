# frozen_string_literal: true

# Each Neighbourhood is ordered by size, biggest to smallest.
# The parent neighbourhood's definition is above, the child's definition is below
FactoryBot.define do
  factory :neighbourhood_region, class: 'Neighbourhood' do
    name { 'North West' }
    name_abbr { 'North West' }
    unit { 'region' }
    unit_code_key { 'RGN19CD' }
    unit_code_value { 'E12000002' }
    unit_name { 'North West' }
  end

  factory :neighbourhood_county, class: 'Neighbourhood' do
    name { 'Greater Manchester' }
    name_abbr { 'Greater Manchester' }
    unit { 'county' }
    unit_code_key { 'CTY19CD' }
    unit_code_value { 'E11000001' }
    unit_name { 'Greater Manchester' }

    after :create do |county|
      county.parent = create(:neighbourhood_region)
      # region = create(:region)
      # county.parent = region
    end
  end

  factory :neighbourhood_district, class: 'Neighbourhood' do
    name { 'Manchester' }
    name_abbr { 'Manchester' }
    unit { 'district' }
    unit_code_key { 'LAD19CD' }
    unit_code_value { 'E08000003' }
    unit_name { 'Manchester' }

    after :create do |district|
      district.parent = create(:neighbourhood_county)
    end
  end

  factory :neighbourhood do
    name { 'Hulme Longname' }
    name_abbr { 'Hulme' }
    unit { 'ward' }
    unit_code_key { 'WD19CD' }
    sequence(:unit_code_value) do |n|
      "E0#{5_011_368 + n}"
    end
    unit_name { 'Hulme' }

    after :create do |ward|
      ward.parent = create(:neighbourhood_district)
      ward.users = [create(:user)]
    end
  end

  factory :ashton_neighbourhood_district, class: 'Neighbourhood' do
    name { 'Tameside' }
    name_abbr { 'Tameside' }
    unit { 'district' }
    unit_code_key { 'LAD19CD' }
    unit_code_value { 'E11000001' }
    unit_name { 'Tameside' }

    after :create do |district|
      district.parent = create(:neighbourhood_county)
    end
  end

  factory :ashton_neighbourhood, class: 'Neighbourhood' do
    name { 'Ashton Hurst' }
    name_abbr { 'Ashton Hurst' }
    unit { 'ward' }
    unit_code_key { 'WD19CD' }
    unit_code_value { 'E05000800' }
    unit_name { 'Ashton Hurst' }

    after :create do |ward|
      ward.parent = create(:ashton_neighbourhood_district)
      ward.users = [create(:user)]
    end
  end
end
