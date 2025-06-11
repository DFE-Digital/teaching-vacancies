module JobApplicationsHelper
  PUBLISHER_STATUS_MAPPINGS = {
    submitted: "unread",
    reviewed: "reviewed",
    shortlisted: "shortlisted",
    unsuccessful: "rejected",
    withdrawn: "withdrawn",
    interviewing: "interviewing",
  }.freeze

  JOBSEEKER_STATUS_MAPPINGS = {
    deadline_passed: "deadline passed",
    draft: "draft",
    submitted: "submitted",
    reviewed: "submitted",
    shortlisted: "shortlisted",
    unsuccessful: "unsuccessful",
    withdrawn: "withdrawn",
  }.freeze

  JOB_APPLICATION_STATUS_TAG_COLOURS = {
    deadline_passed: "grey",
    draft: "pink",
    submitted: "blue",
    reviewed: "purple",
    shortlisted: "green",
    unsuccessful: "red",
    withdrawn: "yellow",
    interviewing: "turquoise",
  }.freeze

  def job_application_qualified_teacher_status_info(job_application)
    case job_application.qualified_teacher_status
    when "yes"
      safe_join([tag.span("Yes, awarded in ", class: "govuk-body", id: "qualified_teacher_status"),
                 tag.span(job_application.qualified_teacher_status_year, class: "govuk-body", id: "qualified_teacher_status_year")])
    when "no"
      safe_join([tag.div("No", class: "govuk-body", id: "qualified_teacher_status"),
                 tag.p(job_application.qualified_teacher_status_details, class: "govuk-body", id: "qualified_teacher_status_details")])
    when "on_track"
      tag.div("I'm on track to receive my QTS", class: "govuk-body", id: "qualified_teacher_status")
    end
  end

  def end_date(date, index = 1)
    return "present" if index.zero?

    date.to_fs(:month_year)
  end

  def job_application_trn(job_application)
    job_application.teacher_reference_number.presence || "None"
  end

  def job_application_support_needed_info(job_application)
    case job_application.is_support_needed
    when true
      safe_join([tag.div("Yes", class: "govuk-body", id: "support_needed"),
                 tag.p(job_application.support_needed_details, class: "govuk-body", id: "support_needed_details")])
    when false
      tag.div("No", id: "support_needed")
    end
  end

  def job_application_close_relationships_info(job_application)
    case job_application.has_close_relationships
    when true
      safe_join([tag.div("Yes", class: "govuk-body", id: "close_relationships"),
                 tag.p(job_application.close_relationships_details, class: "govuk-body", id: "close_relationships_details")])
    when false
      tag.div("No", class: "govuk-body", id: "close_relationships")
    end
  end

  def job_application_safeguarding_issues_info(job_application)
    if job_application.has_safeguarding_issue
      safe_join([tag.div("Yes", class: "govuk-body", id: "safeguarding_issue"),
                 tag.p(job_application.safeguarding_issue_details, class: "govuk-body", id: "safeguarding_issue_details")])
    else
      tag.div("No", class: "govuk-body", id: "safeguarding_issue")
    end
  end

  def job_application_status_tag(status)
    govuk_tag text: JOBSEEKER_STATUS_MAPPINGS[status.to_sym],
              colour: JOB_APPLICATION_STATUS_TAG_COLOURS[JOBSEEKER_STATUS_MAPPINGS[status.to_sym].parameterize.underscore.to_sym],
              classes: "govuk-!-margin-bottom-2"
  end

  def publisher_job_application_status_tag(status, classes: [])
    default_classes = ["application-status", "govuk-!-margin-bottom-2"]
    govuk_tag text: PUBLISHER_STATUS_MAPPINGS[status.to_sym],
              colour: JOB_APPLICATION_STATUS_TAG_COLOURS[status.to_sym],
              classes: (default_classes + classes).join(" ")
  end

  def status_tag_colour(status)
    JOB_APPLICATION_STATUS_TAG_COLOURS[status]
  end

  def job_application_build_submit_button_text
    if redirect_to_review?
      t("buttons.save")
    else
      t("buttons.save_and_continue")
    end
  end

  def job_application_page_title_prefix(form, title)
    if form.errors.any?
      "Error: #{title}"
    else
      title
    end
  end

  def visa_sponsorship_needed_answer(job_application)
    unless job_application.has_right_to_work_in_uk.nil?
      I18n.t("jobseekers.profiles.personal_details.work.options.#{job_application.has_right_to_work_in_uk}")
    end
  end

  def radio_button_legend_hint
    if vacancy.visa_sponsorship_available?
      {
        text: "jobseekers.profiles.personal_details.work.hint.text",
        link: "jobseekers.profiles.personal_details.work.hint.link",
      }
    else
      {
        text: "jobseekers.profiles.personal_details.work.hint.no_visa.text",
        link: "jobseekers.profiles.personal_details.work.hint.no_visa.link",
      }
    end
  end

  def job_application_sample(vacancy)
    JobApplication.new(job_application_attributes.merge(vacancy: vacancy))
  end

  def religious_job_application_sample(vacancy)
    JobApplication.new(job_application_attributes.merge(
                         following_religion: true,
                         faith: "Anglican",
                         religious_reference_type: "referee",
                         religious_referee_name: Faker::Name.name,
                         religious_referee_address: Faker::Address.full_address,
                         ethos_and_aims: "",
                         religious_referee_role: "Priest",
                         religious_referee_email: Faker::Internet.email,
                         religious_referee_phone: Faker::PhoneNumber.phone_number,
                         vacancy: vacancy.dup.tap { |v| v.assign_attributes(religion_type: "other_religion") },
                       ))
  end

  def catholic_job_application_sample(vacancy)
    JobApplication.new(job_application_attributes.merge(
                         following_religion: true,
                         faith: "Roman Catholic",
                         religious_reference_type: "baptism_date",
                         baptism_address: Faker::Address.full_address,
                         baptism_date: Faker::Date.between(from: Date.new(1990, 1, 1), to: Date.new(2004, 1, 1)),
                         vacancy: vacancy.dup.tap { |v| v.assign_attributes(religion_type: "catholic") },
                       ))
  end

  def readable_working_patterns(job_application)
    job_application.working_patterns.map { |working_pattern|
      JobApplication.human_attribute_name("working_patterns.#{working_pattern}").downcase
    }.join(", ").capitalize
  end

  # These are only used to generate example data
  POSSIBLE_DEGREE_GRADES = %w[2.1 2.2 Honours].freeze
  POSSIBLE_OTHER_GRADES = %w[Pass Merit Distinction].freeze

  def job_application_attributes # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
    job_switch_date = Faker::Date.in_date_period(year: 2018)
    {
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
                      job_title: %w[Headteacher Teacher].sample),
          Referee.new(name: "John Thompson",
                      organisation: "Sheffield Secondary School",
                      relationship: "Line manager",
                      email: "john.thompson@english.sheffield.ac.uk",
                      job_title: %w[Headteacher Teacher].sample),
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
    }
  end
end
