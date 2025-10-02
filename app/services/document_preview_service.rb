class DocumentPreviewService # rubocop: disable Metrics/ClassLength
  Document = Data.define(:filename, :data)

  # These are only used to generate example data
  POSSIBLE_DEGREE_GRADES = %w[2.1 2.2 Honours].freeze
  POSSIBLE_OTHER_GRADES = %w[Pass Merit Distinction].freeze

  PREVIEWS = {
    # rubocop:disable Layout/HashAlignment
    plain:           ["job_application", :job_application_sample],
    religious:       ["job_application", :religious_job_application_sample],
    catholic:        ["job_application", :catholic_job_application_sample],
    self_disclosure: ["self_disclosure", :self_disclosure_sample],
    job_reference:   ["job_reference", :job_reference_sample],
    # rubocop:enable Layout/HashAlignment
  }.freeze

  def self.call(...)
    new(...).document
  end

  def initialize(id, vacancy)
    @vacancy = vacancy
    @sample_name, @sample_method = PREVIEWS.fetch(id.to_sym)
  end

  def document
    Document[filename, pdf.render]
  end

  private

  def pdf
    @pdf ||= send(@sample_method, @vacancy)
  end

  def filename
    "#{@sample_name}_#{pdf.object_id}.pdf"
  end

  def job_application_sample(vacancy)
    job_application = build_job_application
    job_application.assign_attributes(vacancy: vacancy)
    JobApplicationPdfGenerator.new(job_application).generate
  end

  def religious_job_application_sample(vacancy)
    job_application = build_job_application
    job_application.assign_attributes(
      following_religion: true,
      faith: "Anglican",
      religious_reference_type: "religious_referee",
      religious_referee_name: Faker::Name.name,
      religious_referee_address: Faker::Address.full_address,
      ethos_and_aims: "I am person of deep faith and wish to inspire the children I teach though God's teachings",
      religious_referee_role: "Priest",
      religious_referee_email: Faker::Internet.email,
      religious_referee_phone: Faker::PhoneNumber.phone_number,
      vacancy: vacancy.dup.tap { |v| v.assign_attributes(religion_type: "other_religion") },
    )

    JobApplicationPdfGenerator.new(job_application).generate
  end

  def catholic_job_application_sample(vacancy)
    job_application = build_job_application
    job_application.assign_attributes(
      following_religion: true,
      faith: "Roman Catholic",
      religious_reference_type: "baptism_date",
      baptism_address: Faker::Address.full_address,
      baptism_date: Faker::Date.between(from: Date.new(1990, 1, 1), to: Date.new(2004, 1, 1)),
      vacancy: vacancy.dup.tap { |v| v.assign_attributes(religion_type: "catholic") },
    )
    JobApplicationPdfGenerator.new(job_application).generate
  end

  def job_reference_sample(_vacancy)
    job_application = build_job_application
    referee = job_application.referees.first
    referee.assign_attributes(
      reference_request: ReferenceRequest.new(job_reference: build_job_reference),
    )
    referee_presenter = RefereePresenter.new(referee)
    ReferencePdfGenerator.new(referee_presenter).generate
  end

  def self_disclosure_sample(_vacancy)
    job_application = build_job_application
    job_application.assign_attributes(
      self_disclosure_request: SelfDisclosureRequest.new(self_disclosure: build_self_disclosure),
    )
    self_disclosure = SelfDisclosurePresenter.new(job_application)
    SelfDisclosurePdfGenerator.new(self_disclosure).generate
  end

  def build_job_application # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
    job_switch_date = Faker::Date.in_date_period(year: 2018)
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
      personal_statement:
      "As an English teacher, I am extremely passionate about instilling a love of reading and the written word into young people. I have been interested in a position at your school for a number of years and was thrilled to see this opportunity. I received my QTS in 2019, and have since worked as an English teacher in a secondary school in Sheffield.<br />
        In the classroom, I always strive to modify my approach to suit a range of abilities and motivation. By planning lessons around my students’ interests, I have been able to inspire even the most unmotivated readers into a love of books. For example, teaching descriptive writing by looking at their favourite sports and persuasive writing via marketing materials for their favourite shops. Furthermore, I have worked with dozens of students for whom English is their second language and nothing motivates me more than seeing that lightbulb moment happen when they can see their own progress. Last year, 95% of my GCSE students passed with grade 5 or above, and I have a proven track record for ensuring all of my KS3 students improve by at least two grades over years 7 to 9.<br />
        Moreover, I believe that good teaching doesn’t just happen in the classroom. I am a strong advocate for student wellbeing and pastoral support and have greatly enjoyed leading a morning form class for the last three years. Also, in my current school I have contributed to the English department by running a weekly book club, and organising several school trips to literary locations such as Haworth and Stratford Upon Avon, as well as visits to see plays on the curriculum.<br />
        I really resonate with your school’s ethos around inclusion and leaving no student behind, and I hope to be an asset to your English department, while continuing to grow as a teacher.",
      employments:
      [
        Employment.new(
          organisation: "Townington Secondary School",
          employment_type: :job,
          job_title: "KS3 Teaching Assistant",
          main_duties: "Pastoral support for students. Managing student behaviour. Monitored students’ progress and gave feedback to teachers.",
          reason_for_leaving: "Moving out of the area",
          subjects: Faker::Educator.subject,
          started_on: Faker::Date.in_date_period(year: 2016),
          is_current_role: false,
          ended_on: job_switch_date,
        ),
        Employment.new(
          employment_type: :break,
          reason_for_break: "Time off to care for elderly parent",
          started_on: job_switch_date,
          ended_on: job_switch_date + 2.months,
          is_current_role: false,
        ),
        Employment.new(
          organisation: "Sheffield Secondary School",
          employment_type: :job,
          job_title: "English Teacher",
          main_duties: "Planning and delivering English Literature and Language lessons ro a range of abilities across KS3 and GCSE to prepare them for exams. Contributing to the English department via extra curricular activities, organising trips, and running a reading club.",
          reason_for_leaving: "No opportunities for career advancement",
          subjects: Faker::Educator.subject,
          started_on: job_switch_date + 2.months,
          is_current_role: true,
        ),
      ],
      referees:
      [
        Referee.new(name: "Laura Davison",
                    organisation: "Townington Secondary School",
                    relationship: "Line manager",
                    email: "l.davison@english.townington.ac.uk",
                    job_title: %w[Headteacher Teacher].sample,
                    phone_number: Faker::PhoneNumber.phone_number),
        Referee.new(name: "John Thompson",
                    organisation: "Sheffield Secondary School",
                    relationship: "Line manager",
                    email: "john.thompson@english.sheffield.ac.uk",
                    job_title: %w[Headteacher Teacher].sample,
                    phone_number: Faker::PhoneNumber.phone_number),
      ],
      training_and_cpds: [
        TrainingAndCpd.new(name: "HQA", provider: "TeachTrainLtd", grade: "Honours", year_awarded: "2020", course_length: "1 year"),
      ],
      qualifications:
      [
        Qualification.new(category: :undergraduate,
                          institution: Faker::Educator.university,
                          year: 2016,
                          subject: "BA English Literature"),
        Qualification.new(category: :other, institution: Faker::Educator.university, year: 2019, subject: "PGCE English with QTS"),
        Qualification.new(category: :a_level, institution: Faker::Educator.secondary_school, year: 2012, qualification_results: [
          QualificationResult.new(subject: "English Literature", grade: "A"),
          QualificationResult.new(subject: "History", grade: "B"),
          QualificationResult.new(subject: "French", grade: "A"),
        ]),
        Qualification.new(category: :gcse, institution: Faker::Educator.secondary_school, year: 2010, qualification_results: [
          QualificationResult.new(subject: "Maths", grade: "A"),
          QualificationResult.new(subject: "English Literature", grade: "A"),
          QualificationResult.new(subject: "English Language", grade: "B"),
          QualificationResult.new(subject: "History", grade: "C"),
          QualificationResult.new(subject: "French", grade: "A"),
          QualificationResult.new(subject: "Music", grade: "B"),
          QualificationResult.new(subject: "Geography", grade: "C"),
        ]),
      ].map do |qual|
        qual.tap do |q|
          q.finished_studying = (q.undergraduate? || q.postgraduate? || q.other? ? Faker::Boolean.boolean : nil)
          q.finished_studying_details = (q.finished_studying == false ? "Stopped due to illness" : "")
          if q.finished_studying?
            q.grade = q.undergraduate? || q.postgraduate? ? POSSIBLE_DEGREE_GRADES.sample : POSSIBLE_OTHER_GRADES.sample
          end
        end
      end,
    )
  end

  def build_job_reference # rubocop: disable Metrics/MethodLength
    JobReference.new(
      complete: true,
      can_give_reference: true,
      name: "Doretta Conroy",
      job_title: "Headmaster",
      phone_number: "01234 5654345",
      email: "gerald_zboncak@contoso.com",
      organisation: "Sample school",
      how_do_you_know_the_candidate: "Officiis est perspiciatis. Est aliquam fuga. Accusamus harum aut.",
      reason_for_leaving: "no reason",
      would_reemploy_current_reason: "wonderful",
      would_reemploy_any_reason: "fantastic",
      currently_employed: false,
      would_reemploy_current: true,
      would_reemploy_any: true,
      employment_start_date: 5.years.ago,
      employment_end_date: 1.day.ago,
      under_investigation: false,
      warnings: false,
      allegations: false,
      not_fit_to_practice: false,
      able_to_undertake_role: true,
      under_investigation_details: "Omnis et ullam adipisci.",
      warning_details: "Vel quibusdam consequuntur laboriosam.",
      unable_to_undertake_reason: "Odit et quos reiciendis.",
      punctuality: "outstanding",
      working_relationships: "outstanding",
      customer_care: "outstanding",
      adapt_to_change: "outstanding",
      deal_with_conflict: "outstanding",
      prioritise_workload: "outstanding",
      team_working: "good",
      communication: "outstanding",
      problem_solving: "outstanding",
      general_attitude: "outstanding",
      technical_competence: "poor",
      leadership: "outstanding",
    )
  end

  def build_self_disclosure # rubocop: disable Metrics/MethodLength
    SelfDisclosure.new(
      name: "Doretta Conroy",
      previous_names: "Neville Torp LLD",
      address_line_1: "682 Keeling Divide",
      address_line_2: "88039 Bartell Manor",
      city: "East Chris",
      postcode: "UC5 7NB",
      country: "Country",
      phone_number: "01234 567890",
      date_of_birth: 20.years.ago,
      has_unspent_convictions: false,
      has_spent_convictions: false,
      is_barred: false,
      has_been_referred: false,
      is_known_to_children_services: false,
      has_been_dismissed: false,
      has_been_disciplined: false,
      has_been_disciplined_by_regulatory_body: false,
      agreed_for_processing: true,
      agreed_for_criminal_record: true,
      agreed_for_organisation_update: true,
      agreed_for_information_sharing: true,
      true_and_complete: true,
    )
  end
end
