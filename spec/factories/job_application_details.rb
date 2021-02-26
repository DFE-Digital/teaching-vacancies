FactoryBot.define do
  factory :job_application_detail do
    details_type { "references" }
    data { { name: "Jim" } }
    job_application

    trait :employment_history do
      details_type { "employment_history" }
      data do
        {
          organisation: Faker::Educator.secondary_school,
          job_title: "Teacher",
          salary: "Pay scale level 3",
          subjects: Faker::Educator.subject,
          main_duties: Faker::Lorem.paragraph(sentence_count: 2),
          started_on: Faker::Date.in_date_period(year: 2016),
          current_role: "no",
          ended_on: Faker::Date.in_date_period(year: 2018),
          reason_for_leaving: Faker::Lorem.paragraph(sentence_count: 2),
        }
      end
    end

    trait :reference do
      details_type { "references" }
      data do
        {
          name: Faker::Name.name,
          job_title: Faker::Company.profession,
          organisation: Faker::Educator.secondary_school,
          relationship_to_applicant: "Line Manager",
          email_address: Faker::Internet.email,
          phone_number: "01234 567890",
        }
      end
    end
  end
end
