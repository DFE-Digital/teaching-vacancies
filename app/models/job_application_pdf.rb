# rubocop:disable Metrics/ClassLength
class JobApplicationPdf
  include JobApplicationsHelper
  include QualificationsHelper

  Table = Data.define(:rows) do
    include Enumerable
    extend Forwardable

    def_delegators :rows, :each, :==, :<<, :empty?
  end

  def initialize(job_application)
    @job_application = job_application
    @vacancy = job_application.vacancy
    @table_class = Table
  end

  attr_reader :table_class

  def religious_application?
    vacancy.catholic? || vacancy.other_religion?
  end

  def header_text
    I18n.t("jobseekers.job_applications.caption", job_title: vacancy.job_title, organisation: vacancy.organisation_name)
  end

  def applicant_name
    job_application.name
  end

  def footer_text
    "#{job_application.name} | #{vacancy.organisation_name}"
  end

  def personal_details
    return @personal_details if @personal_details.present?

    scope = "helpers.label.jobseekers_job_application_personal_details_form"
    ni_review = job_application.national_insurance_number.presence || I18n.t("jobseekers.job_applications.not_defined")

    @personal_details = table_class[basic_personal_details].tap do |table|
      table.rows << [I18n.t("national_insurance_number_review", scope:), ni_review] if job_application.national_insurance_number?

      table.rows << [I18n.t("working_pattern_details", scope:), job_application.working_pattern_details] if job_application.working_pattern_details.present?
    end
  end

  def personal_statement
    if job_application.personal_statement_richtext.present?
      html = job_application.personal_statement_richtext.to_s
      # Convert tags to prawn format (we only need bold and italic)
      html = html.gsub(%r{<strong>(.*?)</strong>}m, '<b>\1</b>')
      html = html.gsub(%r{<em>(.*?)</em>}m, '<i>\1</i>')
      # Strip all HTML tags except b and i so prawn doesn't display them as a string
      ActionView::Base.full_sanitizer.sanitize(html, tags: %w[b i])
    elsif job_application.personal_statement.present?
      job_application.personal_statement
    else
      I18n.t("jobseekers.job_applications.review.personal_statement.blank")
    end
  end

  def professional_status
    return @professional_status if @professional_status.present?

    scope = "helpers.legend.jobseekers_job_application_professional_status_form"
    label_scope = "helpers.label.jobseekers_job_application_personal_details_form"

    basic_professional_status = [
      [I18n.t("qualified_teacher_status", scope:), qualified_teacher_status_info(job_application)],
      [I18n.t("jobseekers.job_application.age_range_and_subject"), optional_value(job_application.qts_age_range_and_subject)],
      [I18n.t("teacher_reference_number_review", scope: label_scope), job_application_trn(job_application)],
      [I18n.t("is_statutory_induction_complete", scope:), yes_no(job_application.is_statutory_induction_complete?)],
    ]

    @professional_status = table_class[basic_professional_status].tap do |table|
      if job_application.statutory_induction_complete_details.present?
        table.rows << [I18n.t("statutory_induction_complete_details", scope:), job_application.statutory_induction_complete_details]
      end
    end
  end

  def qualifications
    return no_data_available(I18n.t("jobseekers.job_applications.show.qualifications.none")) if job_application.qualifications.none?

    qualifications_sort_and_group(job_application.qualifications).each_value.map do |group|
      [qualifications_group_name(group), qualifications_group_data(group)]
    end
  end

  def training_and_cpds
    return no_data_available(I18n.t("jobseekers.job_applications.show.training_and_cpds.none")) if job_application.training_and_cpds.none?

    make_nested_section do
      job_application.training_and_cpds.map do |training|
        table_class[
          [
            ["Name", training.name],
            (["Grade", training.grade] if training.grade.present?),
            (["Provider", training.provider] if training.provider.present?),
            (["Course length", training.course_length] if training.course_length.present?),
            ["Awarded Year", training.year_awarded],
          ].compact,
        ]
      end
    end
  end

  def professional_body_memberships
    return no_data_available(I18n.t("jobseekers.job_applications.review.professional_body_memberships.none")) if job_application.professional_body_memberships.none?

    scope = "helpers.label.jobseekers_professional_body_membership_form.exam_taken_options"
    make_nested_section do
      job_application.professional_body_memberships.map do |membership|
        table_class[
          [
            ["Name of professional body:", membership.name],
            ["Membership type or level:", membership.membership_type],
            ["Membership or registration number:", membership.membership_number],
            ["Date obtained:", membership.year_membership_obtained],
            ["Exam taken for this membership:", I18n.t(membership.exam_taken, scope:)],
          ].reject { |row| row[1].blank? },
        ]
      end
    end
  end

  def religious_information
    religious_data = if vacancy.catholic?
                       catholic_religious_information
                     else
                       non_catholic_religious_information
                     end

    table_class[religious_data]
  end

  def employment_history
    return no_data_available(I18n.t("jobseekers.job_applications.show.employment_history.none")) if job_application.employments.none?

    make_nested_section do
      job_application
        .employments
        .sort_by { |r| r[:started_on] }
        .reverse
        .flat_map
        .with_index { |employment, idx| employment_data(employment, idx) }
    end
  end

  def referees
    return no_data_available(I18n.t("jobseekers.job_applications.show.employment_history.none")) if job_application.referees.none?

    contact_referers = nil
    contact_referers = I18n.t("jobseekers.job_applications.review.contact_referer.publisher") if job_application.notify_before_contact_referers

    make_nested_section(contact_referers) do
      job_application.referees.sort_by(&:created_at).map do |referee|
        reference_data = [
          ["Name:", referee.name],
          ["Job Title:", referee.job_title],
          ["Organisation:", referee.organisation],
          ["Relationship:", referee.relationship],
          ["Email:", referee.email],
        ]

        reference_data << ["Phone Number:", referee.phone_number] if referee.phone_number.present?
        reference_data << ["Current or most recent employer:", I18n.t("helpers.label.jobseekers_job_application_details_referee_form.is_most_recent_employer_options.#{referee.is_most_recent_employer}")] unless referee.is_most_recent_employer.nil?

        table_class[reference_data]
      end
    end
  end

  def ask_for_support
    @ask_for_support ||= table_class[
      [
        [
          I18n.t("helpers.legend.jobseekers_job_application_ask_for_support_form.is_support_needed"),
          yes_details_no(
            job_application.is_support_needed?,
            job_application.support_needed_details,
          ),
        ],
      ],
    ]
  end

  def declarations
    @declarations ||= begin
      safeguarding_issues_info = yes_details_no(job_application.has_safeguarding_issue?, job_application.safeguarding_issue_details)

      group_type = organisation_label_type(job_application.vacancy.organisation)
      close_relationships_info = yes_details_no(job_application.has_close_relationships?, job_application.close_relationships_details)

      scope = "helpers.legend.jobseekers_job_application_declarations_form"

      table_class[
        [
          [I18n.t("has_safeguarding_issue", scope:), safeguarding_issues_info],
          [I18n.t("has_close_relationships.#{group_type}", scope:, organisation: vacancy.organisation_name), close_relationships_info],
        ],
      ]
    end
  end

  private

  def catholic_religious_information
    religious_data = []

    religious_data << [I18n.t("helpers.legend.jobseekers_job_application_catholic_form.following_religion"),
                       I18n.t("helpers.label.jobseekers_job_application_catholic_form.following_religion_options.#{job_application.following_religion}")]

    religious_data += religious_data_fields

    religious_data
  end

  def non_catholic_religious_information
    religious_data = []
    religious_data << [I18n.t("helpers.label.jobseekers_job_application_non_catholic_form.ethos_and_aims"), job_application.ethos_and_aims]
    religious_data << [I18n.t("helpers.legend.jobseekers_job_application_non_catholic_form.following_religion"),
                       I18n.t("helpers.label.jobseekers_job_application_non_catholic_form.following_religion_options.#{job_application.following_religion}")]

    religious_data += religious_data_fields

    religious_data
  end

  def religious_data_fields
    if job_application.following_religion
      religious_data = []

      religious_data << [I18n.t("helpers.label.jobseekers_job_application_catholic_form.faith"), job_application.faith]
      religious_data << [I18n.t("helpers.label.jobseekers_job_application_catholic_form.place_of_worship"), job_application.place_of_worship]

      religious_data << [I18n.t("helpers.legend.jobseekers_job_application_catholic_form.religious_reference_type"),
                         if job_application.religious_reference_type.present?
                           I18n.t("helpers.label.jobseekers_job_application_catholic_form.religious_reference_type_options.#{job_application.religious_reference_type}")
                         else
                           ""
                         end]

      religious_data += religious_reference_data(job_application.religious_reference_type)
      religious_data
    else
      []
    end
  end

  # rubocop:disable Metrics/MethodLength
  def religious_reference_data(religious_reference_type)
    case religious_reference_type
    when "religious_referee"
      [
        [I18n.t("helpers.label.jobseekers_job_application_catholic_form.religious_referee_name"), job_application.religious_referee_name],
        [I18n.t("helpers.label.jobseekers_job_application_catholic_form.religious_referee_address"), job_application.religious_referee_address],
        [I18n.t("helpers.label.jobseekers_job_application_catholic_form.religious_referee_role"), job_application.religious_referee_role],
        [I18n.t("helpers.label.jobseekers_job_application_catholic_form.religious_referee_email"), job_application.religious_referee_email],
        [I18n.t("helpers.label.jobseekers_job_application_catholic_form.religious_referee_phone"), job_application.religious_referee_phone],
      ]
    when "baptism_certificate"
      [
        [I18n.t("jobseekers.job_applications.review.religious_information.baptism_certificate"), job_application.baptism_certificate.filename.to_s],
      ]

    when "baptism_date"
      [
        [I18n.t("helpers.label.jobseekers_job_application_catholic_form.baptism_address"), job_application.baptism_address],
        [I18n.t("helpers.legend.jobseekers_job_application_catholic_form.baptism_date"), job_application.baptism_date.to_fs(:day_month_year)],
      ]
    else
      []
    end
  end
  # rubocop:enable Metrics/MethodLength

  attr_reader :job_application, :vacancy

  def yes_no(bool)
    return "Yes" if bool

    "No"
  end

  def yes_details_no(bool, details)
    return "Yes\nDetails: #{details}" if bool

    "No"
  end

  def no_data_available(text)
    # make an empty nested section data structure rendered by `JobApplicationPdfGenerator.render_nested_section`
    [[text, nil]]
  end

  def make_nested_section(sub_title = nil)
    # make a nested section data structure rendered by `JobApplicationPdfGenerator.render_nested_section`
    [[sub_title, yield]]
  end

  def month_year(date)
    date.to_fs(:month_year)
  end

  def end_date(date, latest_employment_record: false)
    return "present" if latest_employment_record

    month_year(date)
  end

  def optional_value(value)
    value.presence || I18n.t("jobseekers.job_application.not_provided")
  end

  def job_application_address
    job_application.address.join(", ")
  end

  def basic_personal_details
    scope = "helpers.label.jobseekers_job_application_personal_details_form"
    declaration_scope = "helpers.legend.jobseekers_job_application_declarations_form"
    address_scope = "helpers.legend.jobseekers_job_application_personal_details_form"

    [
      [I18n.t("first_name", scope:), job_application.first_name],
      [I18n.t("last_name", scope:), job_application.last_name],
      [I18n.t("previous_names_optional", scope:), optional_value(job_application.previous_names)],
      [I18n.t("your_address", scope: address_scope), job_application_address],
      [I18n.t("phone_number", scope:), job_application.phone_number],
      [I18n.t("email_address", scope:), job_application.email_address],
      [I18n.t("has_right_to_work_in_uk", scope: declaration_scope), visa_sponsorship_needed_answer(job_application)],
      [I18n.t("working_patterns", scope:), readable_working_patterns(job_application)],
    ]
  end

  def qualifications_group_name(group)
    return group.first.name if qualifications_group_category_other?(group)

    I18n.t("helpers.label.jobseekers_qualifications_category_form.category_options.#{group.first[:category]}")
  end

  def qualifications_group_data(group)
    group.flat_map do |qualification|
      if qualification.secondary?
        secondary_qualification_data(qualification)
      else
        general_qualification_data(qualification)
      end
    end
  end

  def secondary_qualification_data(qualification)
    qualification.qualification_results.map do |result|
      table_class[
        [
          ["Secondary Qualification"],
          ["Subject:", result.subject],
          ["Grade:", result.grade],
          (["Awarding Body:", result.awarding_body] if result.awarding_body.present?),
          ["Date completed:", qualification.award_date],
        ].compact,
      ]
    end
  end

  def general_qualification_data(qualification)
    table_class[
      [
        ["Qualification Name:", qualification.name],
        ["Institution:", qualification.institution],
        ["Grade:", qualification.grade],
        ["Date completed:", qualification.award_date],
        ["Awarding body:", qualification.awarding_body],
      ].reject { |row| row[1].blank? },
    ]
  end

  def employment_data(employment, index)
    return [employment_break(employment, index.zero?)] if employment.break?

    gap = job_application.unexplained_employment_gaps[employment]
    if gap.present?
      [employment_unexplained_gap(gap, index.zero?), employment_entry(employment)]
    else
      [employment_entry(employment)]
    end
  end

  def employment_entry(employment)
    employment_data = [
      ["Employment"],
      ["Job Title:", employment.job_title],
      ["School or other:", employment.organisation],
      ["Main duties:", employment.main_duties],
    ]

    employment_data << ["Subjects:", employment.subjects] if employment.subjects.present?
    employment_data << ["Employment currently held:", yes_no(employment.is_current_role?)]
    employment_data << ["Reason for leaving:", employment.reason_for_leaving]
    employment_data << ["End date:", employment.is_current_role? ? "present" : end_date(employment.ended_on)]
    employment_data << ["Start date:", month_year(employment.started_on)]

    table_class[employment_data]
  end

  def employment_break(employment, latest_employment_record)
    table_class[
      [
        ["Employment Break"],
        ["Reason:", employment.reason_for_break],
        ["End date:", end_date(employment.ended_on, latest_employment_record:)],
        ["Start date:", month_year(employment.started_on)],
      ],
    ]
  end

  def employment_unexplained_gap(gap, latest_employment_record)
    table_class[
      [
        ["Unexplained Employment Gap"],
        ["End date:", end_date(gap[:ended_on], latest_employment_record:)],
        ["Start date:", month_year(gap[:started_on])],
      ],
    ]
  end

  def qualified_teacher_status_info(job_application)
    case job_application.qualified_teacher_status
    when "yes"
      "Yes, gained in #{job_application.qualified_teacher_status_year}"
    when "no"
      "No. #{job_application.qualified_teacher_status_details}"
    when "on_track"
      "I'm on track to receive my QTS"
    else
      "Status not provided"
    end
  end
end
# rubocop:enable Metrics/ClassLength
