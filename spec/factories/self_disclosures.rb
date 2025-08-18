FactoryBot.define do
  factory :self_disclosure do
    name { Faker::Name.name }
    previous_names { Faker::Name.name }
    address_line_1 { Faker::Address.street_address }
    address_line_2 { Faker::Address.street_address }
    city { Faker::Address.city }
    postcode { Faker::Address.postcode }
    country { "Country" }
    phone_number { "01234 567890" }
    date_of_birth { 20.years.ago }
    has_unspent_convictions { false }
    has_spent_convictions { false }
    is_barred { false }
    has_been_referred { false }
    is_known_to_children_services { false }
    has_been_dismissed { false }
    has_been_disciplined { false }
    has_been_disciplined_by_regulatory_body { false }
    agreed_for_processing { true }
    agreed_for_criminal_record { true }
    agreed_for_organisation_update { true }
    agreed_for_information_sharing { true }
    true_and_complete { true }
    self_disclosure_request
  end

  trait :pending do
    name { nil }
    previous_names { nil }
    address_line_1 { nil }
    address_line_2 { nil }
    city { nil }
    postcode { nil }
    country { nil }
    phone_number { nil }
    date_of_birth { nil }
    has_unspent_convictions { nil }
    has_spent_convictions { nil }
    is_barred { nil }
    has_been_referred { nil }
    is_known_to_children_services { nil }
    has_been_dismissed { nil }
    has_been_disciplined { nil }
    has_been_disciplined_by_regulatory_body { nil }
    agreed_for_processing { nil }
    agreed_for_criminal_record { nil }
    agreed_for_organisation_update { nil }
    agreed_for_information_sharing { nil }
  end
end
