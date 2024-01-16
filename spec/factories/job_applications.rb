FactoryBot.define do
  factory :job_application do
    transient do
      draft_at { 2.weeks.ago }
      create_details { true }
    end

    status { :draft }
    jobseeker
    vacancy

    # Personal details
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    previous_names { Faker::Name.name }
    street_address { Faker::Address.street_address }
    city { Faker::Address.city }
    postcode { Faker::Address.postcode }
    country { Faker::Address.country }
    email_address { Faker::Internet.email(domain: "example.com") }
    phone_number { "01234 567890" }
    teacher_reference_number { "1234567" }
    national_insurance_number { "QQ 12 34 56 C" }

    # Professional statement
    qualified_teacher_status { "yes" }
    qualified_teacher_status_year { "1990" }
    statutory_induction_complete { "yes" }

    # Education and qualifications
    qualifications_section_completed { true }

    # Employment history
    employment_history_section_completed { true }

    # Personal statement
    personal_statement { Faker::Lorem.paragraph(sentence_count: 8) }

    # Ask for support
    support_needed { "yes" }
    support_needed_details { Faker::Lorem.paragraph(sentence_count: 2) }

    # Equal opportunities
    disability { "no" }
    age { "under_twenty_five" }
    gender { "other" }
    gender_description { Faker::Lorem.sentence }
    orientation { "other" }
    orientation_description { Faker::Lorem.sentence }
    ethnicity { "other" }
    ethnicity_description { Faker::Lorem.sentence }
    religion { "other" }
    religion_description { Faker::Lorem.sentence }

    # Declarations
    close_relationships { "yes" }
    close_relationships_details { Faker::Lorem.paragraph(sentence_count: 1) }
    safeguarding_issue { "yes" }
    safeguarding_issue_details { Faker::Lorem.paragraph(sentence_count: 1) }
    right_to_work_in_uk { "yes" }

    completed_steps { JobApplication.completed_steps.keys }
    in_progress_steps { [] }

    after :create do |job_application, options|
      if options.create_details
        create_list :employment, 3, :job, job_application: job_application
        create_list :employment, 1, :break, job_application: job_application
        create_list :reference, 2, job_application: job_application
        create_list :qualification, 3, job_application: job_application
      end

      job_application.update_columns(
        draft_at: options.draft_at,
        reviewed_at: options.reviewed_at,
        shortlisted_at: options.shortlisted_at,
        submitted_at: options.submitted_at,
        unsuccessful_at: options.unsuccessful_at,
        withdrawn_at: options.withdrawn_at,
      )
    end
  end

  trait :status_draft do
    transient do
      create_details { false }
    end

    status { :draft }

    # Personal details
    first_name { "" }
    last_name { "" }
    previous_names { "" }
    street_address { "" }
    city { "" }
    postcode { "" }
    country { "" }
    email_address { "" }
    phone_number { "" }
    teacher_reference_number { "" }
    national_insurance_number { "" }

    # Professional statement
    qualified_teacher_status { "" }
    qualified_teacher_status_year { "" }
    statutory_induction_complete { "" }

    # Education and qualifications
    qualifications_section_completed { nil }

    # Employment history
    employment_history_section_completed { nil }

    # Personal statement
    personal_statement { "" }

    # Equal opportunities
    disability { "" }
    gender { "" }
    gender_description { "" }
    orientation { "" }
    orientation_description { "" }
    ethnicity { "" }
    ethnicity_description { "" }
    religion { "" }
    religion_description { "" }

    # Ask for support
    support_needed { "" }
    support_needed_details { "" }

    # Declarations
    close_relationships { "" }
    close_relationships_details { "" }
    right_to_work_in_uk { "" }

    completed_steps { [] }
  end

  trait :status_reviewed do
    transient do
      submitted_at { 4.days.ago }
      reviewed_at { 3.days.ago }
    end

    status { :reviewed }
  end

  trait :status_shortlisted do
    transient do
      submitted_at { 4.days.ago }
      reviewed_at { 3.days.ago }
      shortlisted_at { 2.days.ago }
    end

    status { :shortlisted }
    further_instructions { Faker::Lorem.paragraph(sentence_count: 2) }
  end

  trait :status_submitted do
    transient do
      submitted_at { 4.days.ago }
    end

    status { :submitted }
  end

  trait :status_unsuccessful do
    transient do
      submitted_at { 4.days.ago }
      reviewed_at { 3.days.ago }
      unsuccessful_at { 2.days.ago }
    end

    status { :unsuccessful }
    rejection_reasons { Faker::Lorem.paragraph(sentence_count: 1) }
  end

  trait :status_withdrawn do
    transient do
      submitted_at { 4.days.ago }
      withdrawn_at { 2.days.ago }
    end

    status { :withdrawn }
  end

  trait :job_application_sample do
    first_name { "Jane" }
    last_name { "Smith" }
    previous_names { "Churchill" }
    street_address { "1 House Street" }
    city { "Townington" }
    postcode { "AB1 2CD" }
    country { "England" }
    phone_number { "07123456789" }
    teacher_reference_number { "123456" }
    qualified_teacher_status { "yes" }
    qualified_teacher_status_year { "2021" }
    email_address { "jane.smith@gmail.com" }
    support_needed { "yes" }
    support_needed_details { "I require a wheelchair accessible room for an interview" }
    close_relationships { "yes" }
    close_relationships_details { "Brother-in-law works at the trust" }

    personal_statement do
      "As an English teacher, I am extremely passionate about instilling a love of reading and the written word into young people. I have been interested in a position at your school for a number of years and was thrilled to see this opportunity. I received my QTS in 2019, and have since worked as an English teacher in a secondary school in Sheffield.<br />
    In the classroom, I always strive to modify my approach to suit a range of abilities and motivation. By planning lessons around my students’ interests, I have been able to inspire even the most unmotivated readers into a love of books. For example, teaching descriptive writing by looking at their favourite sports and persuasive writing via marketing materials for their favourite shops. Furthermore, I have worked with dozens of students for whom English is their second language and nothing motivates me more than seeing that lightbulb moment happen when they can see their own progress. Last year, 95% of my GCSE students passed with grade 5 or above, and I have a proven track record for ensuring all of my KS3 students improve by at least two grades over years 7 to 9.<br />
    Moreover, I believe that good teaching doesn’t just happen in the classroom. I am a strong advocate for student wellbeing and pastoral support and have greatly enjoyed leading a morning form class for the last three years. Also, in my current school I have contributed to the English department by running a weekly book club, and organising several school trips to literary locations such as Haworth and Stratford Upon Avon, as well as visits to see plays on the curriculum.<br />
    I really resonate with your school’s ethos around inclusion and leaving no student behind, and I hope to be an asset to your English department, while continuing to grow as a teacher."
    end

    employment_history_section_completed { true }

    employments do
      [
        association(:employment, :employment1),
        association(:employment, :employment2),
      ]
    end

    references do
      [
        association(:reference, :reference1),
        association(:reference, :reference2),
      ]
    end

    qualifications do
      [
        association(:qualification, :category_undergraduate),
        association(:qualification, :category_other),
        association(:qualification, :category_a_level),
        association(:qualification, :category_gcse),
      ]
    end
  end
end
