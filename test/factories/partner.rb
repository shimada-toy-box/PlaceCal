# frozen_string_literal: true

FactoryBot.define do
  factory :partner do
    sequence(:name) do |n|
      "Community Group #{n}"
    end

    public_name { 'Partner Contact Name' }
    public_email { 'contact@communitygroup.org' }
    public_phone { '0161 0000000' }

    partner_email { 'admin@communitygroup.org' }
    partner_name { 'Addy Minny Strator' }
    partner_phone { '0161 0000001' }

    summary { 'A cool garden centre' }
    description { 'Our cool garden centre is a very cool and neat garden centre. Come to our events. Now.' }
    url { 'http://example.com' }

    facebook_link { 'facebookgroup' }

    address

    factory :bare_partner, class: 'Partner' do
      address nil
    end

    # after(:build) { |partner| partner.tags = [create(:tag)] }
    # image nil

    factory :moss_side_partner, class: 'Partner' do
      association :address, factory: :moss_side_address
    end

    factory :rusholme_partner, class: 'Partner' do
      association :address, factory: :rusholme_address
    end

    factory :ashton_partner, class: 'Partner' do
      association :address, factory: :ashton_address
    end

    factory :ashton_service_area_partner, class: 'Partner' do
      service_areas do
        build_list(:ashton_service_area, 1)
      end
    end

    opening_times do
      '[ { "@type": "OpeningHoursSpecification",'\
        '    "closes": "20:00:00",'\
        '    "dayOfWeek": "http://schema.org/Monday",'\
        '    "opens": "09:00:00"'\
        '  },'\
        '  { "@type": "OpeningHoursSpecification",'\
        '    "closes": "17:00:00",'\
        '    "dayOfWeek": "http://schema.org/Tuesday",'\
        '    "opens": "09:00:00"'\
        '  },'\
        '  { "@type": "OpeningHoursSpecification",'\
        '    "closes": "17:00:00",'\
        '    "dayOfWeek": "http://schema.org/Wednesday",'\
        '    "opens": "09:00:00"'\
        '  },'\
        '  { "@type": "OpeningHoursSpecification",'\
        '    "closes": "17:00:00",'\
        '    "dayOfWeek": "http://schema.org/Thursday",'\
        '    "opens": "09:00:00"'\
        '  },'\
        '  { "@type": "OpeningHoursSpecification",'\
        '    "closes": "17:00:00",'\
        '    "dayOfWeek": "http://schema.org/Friday",'\
        '    "opens": "09:00:00"'\
        '  },'\
        '  { "@type": "OpeningHoursSpecification",'\
        '    "closes": "13:00:00",'\
        '    "dayOfWeek": "http://schema.org/Saturday",'\
        '    "opens": "09:00:00"'\
        '  }'\
        ']'
    end

    factory :place do
      sequence(:name) do |n|
        "Community Venue #{n}"
      end

      public_name { 'Place Contact Name' }
      public_email { 'contact@venue.org' }
    end
  end
end
