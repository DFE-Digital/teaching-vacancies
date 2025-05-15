FactoryBot.define do
  factory :self_disclosure do
    name { "MyString" }
    previous_names { "MyString" }
    address_line_1 { "MyString" }
    address_line_2 { "MyString" }
    city { "MyString" }
    county { "MyString" }
    postcode { "MyString" }
    phone_number { "MyString" }
    date_of_birth { "MyString" }
    has_unspent_convictions { "MyString" }
    has_spent_convictions { "MyString" }
    is_barred { "MyString" }
    has_been_referred { "MyString" }
    is_known_to_children_services { "MyString" }
    has_been_dismissed { "MyString" }
    has_been_disciplined { "MyString" }
    has_been_disciplined_by_regulatory_body { "MyString" }
    agreed_for_processing { "MyString" }
    agreed_for_criminal_record { "MyString" }
    agreed_for_organisation_update { "MyString" }
    agreed_for_information_sharing { "MyString" }
    signature { "MyString" }
    job_application { nil }
  end
end
