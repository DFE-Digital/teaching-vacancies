FactoryBot.define do
  factory :equal_opportunities_report do
    association :vacancy

    total_submissions { 1 }
    disability_no { 1 }
    disability_prefer_not_to_say { 0 }
    disability_yes { 0 }
    gender_man { 0 }
    gender_other { 1 }
    gender_prefer_not_to_say { 0 }
    gender_woman { 0 }
    gender_other_descriptions { [Faker::Lorem.paragraph(sentence_count: 1)] }
    orientation_bisexual { 0 }
    orientation_gay_or_lesbian { 0 }
    orientation_heterosexual { 0 }
    orientation_other { 1 }
    orientation_prefer_not_to_say { 0 }
    orientation_other_descriptions { [Faker::Lorem.paragraph(sentence_count: 1)] }
    ethnicity_asian { 0 }
    ethnicity_black { 0 }
    ethnicity_mixed { 0 }
    ethnicity_other { 1 }
    ethnicity_prefer_not_to_say { 0 }
    ethnicity_white { 0 }
    ethnicity_other_descriptions { [Faker::Lorem.paragraph(sentence_count: 1)] }
    religion_buddhist { 0 }
    religion_christian { 0 }
    religion_hindu { 0 }
    religion_jewish { 0 }
    religion_muslim { 0 }
    religion_none { 0 }
    religion_other { 1 }
    religion_prefer_not_to_say { 0 }
    religion_sikh { 0 }
    religion_other_descriptions { [Faker::Lorem.paragraph(sentence_count: 1)] }
    age_under_twenty_five { 1 }
    age_twenty_five_to_twenty_nine { 0 }
    age_prefer_not_to_say { 0 }
    age_thirty_to_thirty_nine { 0 }
    age_forty_to_forty_nine { 0 }
    age_fifty_to_fifty_nine { 0 }
    age_sixty_and_over { 0 }
  end
end
