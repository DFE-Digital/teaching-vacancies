FactoryGirl.define do
  factory :vacancy do
    association :pay_scale
    association :subject
    association :leadership
    association :school

    job_title { Faker::Job.title }
    headline { Faker::Lorem.sentence }
    working_pattern { :full_time }
    sequence(:slug) { |n| [job_title.downcase.parameterize, n].join('-') }
    job_description { Faker::Lorem.paragraph(4) }
    essential_requirements { Faker::Lorem.paragraph(4) }
    status { :published }
    expires_on { Faker::Time.forward(14) }
    publish_on { Faker::Time.backward(2) }
    minimum_salary { Faker::Number.number(5) }
    maximum_salary { Faker::Number.number(5) }

    trait :draft do
      status { :draft }
    end

    trait :expired do
      expires_on { Faker::Time.backward(7) }
    end
  end
end