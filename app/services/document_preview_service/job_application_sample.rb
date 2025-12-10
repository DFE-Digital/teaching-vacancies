class DocumentPreviewService::JobApplicationSample
  POSSIBLE_DEGREE_GRADES = %w[2.1 2.2 Honours].freeze
  POSSIBLE_OTHER_GRADES = %w[Pass Merit Distinction].freeze
  SUBJECTS = ["Maths", "English Literature", "English Language", "History", "French", "Music"].freeze
  GRADES = %w[A B C].freeze

  def self.build(vacancy,
                 referees: 2,
                 employments: %i[job break job],
                 training_and_cpds: 3,
                 qualifications: { gcse: 3, a_level: 3, undergraduate: 1, postgraduate: 1, other: 1 },
                 professional_body_memberships: 2)
    builder = new
    builder.job_application.tap do |job_application|
      job_application.vacancy = vacancy
      job_application.referees = builder.referees(referees)
      job_application.employments = builder.employments(employments)
      job_application.training_and_cpds = builder.training_and_cpds(training_and_cpds)
      job_application.qualifications = builder.qualifications(**qualifications)
      job_application.professional_body_memberships = builder.professional_body_memberships(professional_body_memberships)
      job_application.personal_statement_richtext = builder.personal_statement

      case vacancy.religion_type
      when "other_religion"
        job_application.assign_attributes(**religious_attributes)
      when "catholic"
        job_application.assign_attributes(**catholic_attributes)
      end
    end
  end

  def self.religious_attributes
    {
      following_religion: true,
      faith: "Anglican",
      religious_reference_type: "religious_referee",
      religious_referee_name: Faker::Name.name,
      religious_referee_address: Faker::Address.full_address,
      ethos_and_aims: "I am person of deep faith and wish to inspire the children I teach though God's teachings",
      religious_referee_role: "Priest",
      religious_referee_email: Faker::Internet.email,
      religious_referee_phone: Faker::PhoneNumber.phone_number,
    }
  end

  def self.catholic_attributes
    {
      following_religion: true,
      faith: "Roman Catholic",
      religious_reference_type: "baptism_date",
      baptism_address: Faker::Address.full_address,
      baptism_date: Faker::Date.between(from: Date.new(1990, 1, 1), to: Date.new(2004, 1, 1)),
    }
  end

  # rubocop:disable Metrics/MethodLength
  def job_application
    JobApplication.new(
      first_name: "Jane",
      last_name: "Smith",
      national_insurance_number: "QQ 12 34 56 C",
      working_patterns: %w[part_time job_share],
      previous_names: "Churchill",
      street_address: "1 House Street",
      city: "Townington",
      postcode: "AB1 2CD",
      country: "England",
      phone_number: "07123456789",
      teacher_reference_number: "1234567",
      qualified_teacher_status: "yes",
      is_statutory_induction_complete: true,
      qts_age_range_and_subject: "Ages 11-16, English and Maths",
      has_right_to_work_in_uk: true,
      has_safeguarding_issue: false,
      safeguarding_issue_details: "",
      qualified_teacher_status_year: "2021",
      email_address: "jane.smith@gmail.com",
      is_support_needed: true,
      support_needed_details: "I require a wheelchair accessible room for an interview",
      has_close_relationships: true,
      close_relationships_details: "Brother-in-law works at the trust",
      working_pattern_details: "I use differentiated teaching methods to engage diverse learners and ensure all pupils can access the curriculum effectively. I create an inclusive classroom environment that encourages active participation and builds pupils' confidence as independent learners.",
    )
  end
  # rubocop:enable Metrics/MethodLength

  def personal_statement
    "As an English teacher, I am extremely passionate about instilling a love of reading and the written word into young people. I have been interested in a position at your school for a number of years and was thrilled to see this opportunity. I received my QTS in 2019, and have since worked as an English teacher in a secondary school in Sheffield.
      In the classroom, I always strive to modify my approach to suit a range of abilities and motivation. By planning lessons around my students’ interests, I have been able to inspire even the most unmotivated readers into a love of books. For example, teaching descriptive writing by looking at their favourite sports and persuasive writing via marketing materials for their favourite shops. Furthermore, I have worked with dozens of students for whom English is their second language and nothing motivates me more than seeing that light bulb moment happen when they can see their own progress. Last year, 95% of my GCSE students passed with grade 5 or above, and I have a proven track record for ensuring all of my KS3 students improve by at least two grades over years 7 to 9.
      Moreover, I believe that good teaching doesn’t just happen in the classroom. I am a strong advocate for student well-being and pastoral support and have greatly enjoyed leading a morning form class for the last three years. Also, in my current school I have contributed to the English department by running a weekly book club, and organising several school trips to literary locations such as Haworth and Stratford Upon Avon, as well as visits to see plays on the curriculum.
      I really resonate with your school’s ethos around inclusion and leaving no student behind, and I hope to be an asset to your English department, while continuing to grow as a teacher."
  end

  def job(started_on, ended_on, is_current_role)
    Employment.new(organisation: "Townington Secondary School",
                   employment_type: :job,
                   job_title: "KS3 Teaching Assistant",
                   main_duties: "Pastoral support for students. Managing student behaviour. Monitored students’ progress and gave feedback to teachers.",
                   reason_for_leaving: "Moving out of the area",
                   subjects: Faker::Educator.subject,
                   started_on:,
                   ended_on:,
                   is_current_role:)
  end

  def break(started_on, ended_on, is_current_role)
    Employment.new(employment_type: :break,
                   reason_for_break: "Time off to care for elderly parent",
                   started_on:,
                   ended_on:,
                   is_current_role:)
  end

  def employments(employment_types)
    base = employment_types.size
    employment_types.map.with_index do |employment_type, index|
      is_current_role = index + 1 == base
      started_on = (base - index).years.ago
      ended_on = (base - index - 1).years.ago
      send(:"#{employment_type}", started_on, ended_on, is_current_role)
    end
  end

  def referees(quantity)
    Array.new(quantity) do
      Referee.new(name: Faker::Name.name,
                  organisation: "Townington Secondary School",
                  relationship: "Line manager",
                  email: Faker::Internet.email(domain: "english.townington.ac.uk"),
                  job_title: %w[Headteacher Teacher].sample,
                  phone_number: Faker::PhoneNumber.phone_number)
    end
  end

  def training_and_cpds(quantity)
    Array.new(quantity) do
      TrainingAndCpd.new(name: "HQA", provider: "TeachTrainLtd", grade: POSSIBLE_DEGREE_GRADES.sample, year_awarded: "2020", course_length: "1 year")
    end
  end

  def qualification_gcse(quantity)
    Qualification.new(category: :gcse,
                      institution: Faker::Educator.secondary_school,
                      year: 2010,
                      qualification_results: Array.new(quantity) { QualificationResult.new(subject: SUBJECTS.sample, grade: GRADES.sample) })
  end

  def qualification_a_level(quantity)
    Qualification.new(category: :a_level,
                      institution: Faker::Educator.secondary_school,
                      year: 2012,
                      qualification_results: Array.new(quantity) { QualificationResult.new(subject: SUBJECTS.sample, grade: GRADES.sample) })
  end

  def qualification_other(quantity)
    Array.new(quantity) do
      Qualification.new(category: :other,
                        institution: Faker::Educator.university,
                        year: 2019,
                        subject: "PGCE English with QTS",
                        finished_studying: false,
                        finished_studying_details: "Stopped due to illness")
    end
  end

  def qualification_undergraduate(quantity)
    Array.new(quantity) do
      Qualification.new(category: :undergraduate,
                        institution: Faker::Educator.university,
                        year: 2016,
                        subject: "BA English Literature",
                        finished_studying: true,
                        finished_studying_details: "Honours",
                        grade: POSSIBLE_DEGREE_GRADES.sample)
    end
  end

  def qualification_postgraduate(quantity)
    Array.new(quantity) do
      Qualification.new(category: :postgraduate,
                        institution: Faker::Educator.university,
                        year: 2016,
                        subject: "Phd English Literature",
                        finished_studying: true,
                        finished_studying_details: "Honours",
                        grade: POSSIBLE_DEGREE_GRADES.sample)
    end
  end

  def qualifications(gcse:, a_level:, undergraduate:, postgraduate:, other:)
    [
      qualification_gcse(gcse),
      qualification_a_level(a_level),
      *qualification_undergraduate(undergraduate),
      *qualification_postgraduate(postgraduate),
      *qualification_other(other),
    ].flatten
  end

  def professional_body_memberships(quantity)
    Array.new(quantity) do
      ProfessionalBodyMembership.new(name: "Teachers Union",
                                     membership_type: "Platinium",
                                     membership_number: 100,
                                     year_membership_obtained: 2020,
                                     exam_taken: true)
    end
  end
end
