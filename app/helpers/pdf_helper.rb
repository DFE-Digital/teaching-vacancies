# rubocop:disable Metrics/AbcSize
module PdfHelper
  include JobApplicationsHelper
  include QualificationsHelper

  def add_section_title(pdf, title)
    pdf.move_down 20
    pdf.text title, size: 18, style: :bold
    pdf.move_down 10
  end

  def render_table(pdf, data)
    pdf.table(data, cell_style: { borders: [] }) do
      cells.padding = 12
      cells.borders = []
      columns(0).font_style = :bold
      columns(0).align = :left
      columns(1).align = :left
      columns(0).width = 150
    end
  end

  def add_headers(pdf)
    caption_text = I18n.t("jobseekers.job_applications.caption", job_title: vacancy.job_title, organisation: vacancy.organisation_name)
    pdf.text caption_text, size: 12, style: :italic
    pdf.move_down 10
    pdf.text job_application.name, size: 24, style: :bold
    pdf.move_down 20
  end

  def add_personal_details(pdf)
    personal_details = [
      [I18n.t("helpers.label.jobseekers_job_application_personal_details_form.first_name"), job_application.first_name],
      [I18n.t("helpers.label.jobseekers_job_application_personal_details_form.last_name"), job_application.last_name],
      [I18n.t("helpers.legend.jobseekers_job_application_personal_details_form.your_address"),
       [job_application.street_address, job_application.city, job_application.postcode, job_application.country].compact.join(", ")],
      [I18n.t("helpers.label.jobseekers_job_application_personal_details_form.phone_number"), job_application.phone_number],
      [I18n.t("helpers.label.jobseekers_job_application_personal_details_form.email_address"), job_application.email],
      [I18n.t("helpers.legend.jobseekers_job_application_declarations_form.right_to_work_in_uk"), visa_sponsorship_needed_answer(job_application)],
    ]

    if job_application.national_insurance_number?
      personal_details << [
        I18n.t("helpers.label.jobseekers_job_application_personal_details_form.national_insurance_number_review"),
        job_application.national_insurance_number.presence || I18n.t("jobseekers.job_applications.not_defined"),
      ]
    end

    add_section_title(pdf, "Personal Details")
    render_table(pdf, personal_details)
  end

  def add_professional_status(pdf)
    professional_status = [
      [I18n.t("helpers.legend.jobseekers_job_application_professional_status_form.qualified_teacher_status"), job_application_qualified_teacher_status_info(job_application)],
      [I18n.t("helpers.label.jobseekers_job_application_personal_details_form.teacher_reference_number_review"), job_application_jobseeker_profile_info(job_application)],
      [I18n.t("helpers.legend.jobseekers_job_application_professional_status_form.statutory_induction_complete"), job_application.statutory_induction_complete.humanize],
    ]

    add_section_title(pdf, "Professional Status")
    render_table(pdf, professional_status)
  end

  def add_qualifications(pdf)
    pdf.start_new_page

    add_section_title(pdf, "Qualifications")

    if job_application.qualifications.none?
      pdf.text I18n.t("jobseekers.job_applications.show.qualifications.none"), size: 12
    else
      qualifications_sort_and_group(job_application.qualifications).each_value do |qualification_group|
        qualification_group.each do |qualification|
          pdf.move_down 10
          pdf.text qualifications_group_category_other?(qualification_group) ? qualification.name : I18n.t("helpers.label.jobseekers_qualifications_category_form.category_options.#{qualification_group.first[:category]}"), size: 14, style: :bold

          if qualification.secondary?
            add_secondary_qualification_details(pdf, qualification)
          else
            add_general_qualification_details(pdf, qualification)
          end
        end
      end
    end
  end

  def add_secondary_qualification_details(pdf, qualification)
    pdf.move_down 5
    pdf.text "Secondary Qualification", size: 12, style: :italic

    secondary_qualification_data = [
      ["Name:", qualification.name],
      ["Grade:", qualification.grade],
      ["Year Awarded:", qualification.year],
    ].reject { |row| row[1].blank? }

    render_table(pdf, secondary_qualification_data)
  end

  def add_general_qualification_details(pdf, qualification)
    pdf.move_down 5

    general_qualification_data = [
      ["Qualification Name:", qualification.name],
      ["Institution:", qualification.institution],
      ["Grade:", qualification.grade],
      ["Year Awarded:", qualification.year],
    ].reject { |row| row[1].blank? }

    render_table(pdf, general_qualification_data)
  end

  def add_training_and_cpds(pdf)
    pdf.move_down 5
    add_section_title(pdf, "Training and CPD")

    if job_application.training_and_cpds.none?
      pdf.text I18n.t("jobseekers.job_applications.show.training_and_cpds.none"), size: 12
    else
      job_application.training_and_cpds.each do |training|
        pdf.move_down 10

        if training.grade.present?
          pdf.text "#{training.name} (#{training.grade})", size: 14, style: :bold
        else
          pdf.text training.name, size: 14, style: :bold
        end

        pdf.text "#{training.provider}, #{training.year_awarded}", size: 12, style: :italic
      end
    end
  end

  def add_employment_history(pdf)
    pdf.start_new_page
    add_section_title(pdf, "Employment History")

    if job_application.employments.none?
      render_no_employment_message(pdf)
    else
      job_application.employments.sort_by { |r| r[:started_on] }.reverse.each_with_index do |employment, _index|
        render_employment_entry(pdf, employment)
        render_employment_break(pdf, employment)
        render_unexplained_gap(pdf, employment)
      end
    end
  end

  def add_personal_statement(pdf)
    pdf.start_new_page
    add_section_title(pdf, "Personal Statement")

    if job_application.personal_statement.present?
      pdf.text job_application.personal_statement, size: 12, leading: 4
    else
      pdf.text I18n.t(".personal_statement.blank"), size: 12, style: :italic
    end
  end

  def add_references(pdf)
    pdf.start_new_page

    add_section_title(pdf, "References")

    if job_application.references.none?
      pdf.text I18n.t("jobseekers.job_applications.show.employment_history.none"), size: 12
    else
      job_application.references.sort_by(&:created_at).each do |reference|
        pdf.move_down 10
        pdf.text reference.name, size: 14, style: :bold

        reference_data = [
          ["Job Title:", reference.job_title],
          ["Organisation:", reference.organisation],
          ["Relationship:", reference.relationship],
          ["Email:", reference.email],
        ]

        reference_data << ["Phone Number:", reference.phone_number] if reference.phone_number.present?

        render_table(pdf, reference_data)
      end
    end
  end

  def add_ask_for_support(pdf)
    pdf.start_new_page

    add_section_title(pdf, "Ask for Support")

    support_data = [
      [
        I18n.t("helpers.legend.jobseekers_job_application_ask_for_support_form.support_needed"),
        job_application_support_needed_info(job_application),
      ],
    ]

    render_table(pdf, support_data)
  end

  def add_declarations(pdf)
    pdf.move_down 50

    add_section_title(pdf, "Declarations")

    safeguarding_issues_info = pdf_job_application_safeguarding_issues_info
    close_relationships_info = pdf_job_application_close_relationships_info

    declarations_data = [
      [I18n.t("helpers.legend.jobseekers_job_application_declarations_form.safeguarding_issue"), safeguarding_issues_info],
      [I18n.t("helpers.legend.jobseekers_job_application_declarations_form.close_relationships", organisation: vacancy.organisation_name), close_relationships_info],
    ]

    render_table(pdf, declarations_data)
  end

  def add_image_to_first_page(pdf)
    image_path = Rails.root.join("app", "assets", "images", "TVS-logo.png")
    pdf.image image_path, at: [pdf.bounds.right - 100, pdf.bounds.top], width: 100
  end

  def add_footers(pdf)
    applicant_name = job_application.name
    school_name = vacancy.organisation_name

    pdf.repeat(:all, dynamic: true) do
      pdf.bounding_box([pdf.bounds.left, pdf.bounds.bottom + 25], width: pdf.bounds.width) do
        pdf.text "#{applicant_name} | #{school_name}", size: 8, align: :center
      end
    end
  end

  private

  def render_no_employment_message(pdf)
    pdf.text I18n.t("jobseekers.job_applications.review.employment_history.none"), size: 12
  end

  def render_employment_entry(pdf, employment)
    pdf.move_down 10
    pdf.text employment.job_title, size: 14, style: :bold

    employment_data = [
      ["Organisation:", employment.organisation],
      ["Main Duties:", employment.main_duties],
      ["Started on:", employment.started_on.to_formatted_s(:month_year)],
      ["Current Role:", employment.current_role.humanize],
    ]

    employment_data << ["Subjects:", employment.subjects.presence || I18n.t("jobseekers.job_applications.not_defined")] if employment.subjects.present?
    employment_data << ["Ended on:", employment.ended_on.to_formatted_s(:month_year)] if employment.current_role == "no"
    employment_data << ["Reason for Leaving:", employment.reason_for_leaving] if employment.reason_for_leaving.present?

    render_table(pdf, employment_data)
  end

  def render_employment_break(pdf, employment)
    return unless employment.break?

    pdf.move_down 5
    pdf.text "Employment Break", size: 12, style: :italic
    pdf.text employment.reason_for_break, size: 12
  end

  def render_unexplained_gap(pdf, employment)
    gap = job_application.unexplained_employment_gaps[employment]
    return unless gap.present?

    pdf.move_down 5
    pdf.text "Unexplained Employment Gap", size: 12, style: :italic
    pdf.text gap.to_s, size: 12
  end

  def pdf_job_application_safeguarding_issues_info
    case job_application.safeguarding_issue
    when "yes"
      "Yes\nDetails: #{job_application.safeguarding_issue_details}"
    when "no"
      "No"
    else
      "No information provided"
    end
  end

  def pdf_job_application_close_relationships_info
    case job_application.close_relationships
    when "yes"
      "Yes\nDetails: #{job_application.close_relationships_details}"
    when "no"
      "No"
    else
      "No information provided"
    end
  end

  def job_application_support_needed_info(job_application)
    case job_application.support_needed
    when "yes"
      "Yes\nDetails: #{job_application.support_needed_details}"
    when "no"
      "No"
    else
      "No information provided"
    end
  end

  def job_application_qualified_teacher_status_info(job_application)
    case job_application.qualified_teacher_status
    when "yes"
      "Yes, awarded in #{job_application.qualified_teacher_status_year}"
    when "no"
      "No. #{job_application.qualified_teacher_status_details}"
    when "on_track"
      "I'm on track to receive my QTS"
    else
      "Status not provided"
    end
  end
end
# rubocop:enable Metrics/AbcSize
