FactoryBot.define do
  factory :qualification_result do
    qualification

    subject { Faker::Educator.subject }
    grade { factory_sample(%w[A B C D E F]) }

    trait :category_gcse_sample1 do
      subject { "Maths" }
      grade { "A" }
    end

    trait :category_gcse_sample2 do
      subject { "English Literature" }
      grade { "A" }
    end

    trait :category_gcse_sample3 do
      subject { "English Language" }
      grade { "B" }
    end

    trait :category_gcse_sample4 do
      subject { "History" }
      grade { "C" }
    end

    trait :category_gcse_sample5 do
      subject { "French" }
      grade { "A" }
    end

    trait :category_gcse_sample6 do
      subject { "Music" }
      grade { "B" }
    end

    trait :category_gcse_sample7 do
      subject { "Geography" }
      grade { "C" }
    end

    trait :category_alevel_sample1 do
      subject { "English Literature" }
      grade { "A" }
    end

    trait :category_alevel_sample2 do
      subject { "History" }
      grade { "B" }
    end

    trait :category_alevel_sample3 do
      subject { "French" }
      grade { "A" }
    end
  end
end
