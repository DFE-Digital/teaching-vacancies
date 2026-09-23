# Raw hashes shaped like DfE Sign In API responses, not models. The /users and
# /users/approvers endpoints shape the organisation differently (PascalCase keys and a bare
# category id for users, camelCase keys and a nested category for approvers), hence two
# factories. Build them with `build`; there is nothing to save.
FactoryBot.define do
  factory :dsi_user, class: Hash do
    skip_create

    transient do
      user_id { SecureRandom.uuid.upcase }
      email { Faker::Internet.email(domain: "contoso.com") }
      given_name { Faker::Name.first_name }
      family_name { Faker::Name.last_name }
      role_id { 10_000 }
      role_name { "End user" }
      approved_at { "2026-01-01T00:00:00.000Z" }
      updated_at { "2026-01-02T00:00:00.000Z" }
      school_urn { factory_rand(100_000..999_999).to_s }
      trust_uid { nil }
      category { Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:single_establishment] }
      establishment_number { nil }
    end

    trait :trust do
      school_urn { nil }
      trust_uid { factory_rand(10_000..99_999).to_s }
      category { Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:multi_academy_trust] }
    end

    trait :local_authority do
      school_urn { nil }
      category { Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:local_authority] }
      establishment_number { factory_rand(800..999).to_s }
    end

    initialize_with do
      {
        "userId" => user_id,
        "email" => email,
        "givenName" => given_name,
        "familyName" => family_name,
        "roleId" => role_id,
        "roleName" => role_name,
        "approvedAt" => approved_at,
        "updatedAt" => updated_at,
        "organisation" => {
          "URN" => school_urn,
          "UID" => trust_uid,
          "Category" => category,
          "EstablishmentNumber" => establishment_number,
        },
      }
    end
  end

  factory :dsi_approver, class: Hash do
    skip_create

    transient do
      user_id { SecureRandom.uuid.upcase }
      email { Faker::Internet.email(domain: "contoso.com") }
      given_name { Faker::Name.first_name }
      family_name { Faker::Name.last_name }
      role_id { "approver" }
      role_name { "Approver" }
      school_urn { factory_rand(100_000..999_999).to_s }
      trust_uid { nil }
      category { Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:single_establishment] }
      establishment_number { nil }
    end

    trait :trust do
      school_urn { nil }
      trust_uid { factory_rand(10_000..99_999).to_s }
      category { Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:multi_academy_trust] }
    end

    trait :local_authority do
      school_urn { nil }
      category { Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:local_authority] }
      establishment_number { factory_rand(800..999).to_s }
    end

    initialize_with do
      {
        "userId" => user_id,
        "email" => email,
        "givenName" => given_name,
        "familyName" => family_name,
        "roleId" => role_id,
        "roleName" => role_name,
        "organisation" => {
          "urn" => school_urn,
          "uid" => trust_uid,
          "category" => { "id" => category },
          "establishmentNumber" => establishment_number,
        },
      }
    end
  end

  # One page of a /users or /users/approvers response.
  factory :dsi_users_page, class: Hash do
    skip_create

    transient do
      users { [] }
      page { 1 }
      number_of_pages { 1 }
    end

    initialize_with do
      {
        "users" => users,
        "numberOfRecords" => users.size,
        "page" => page,
        "numberOfPages" => number_of_pages,
      }
    end
  end
end
