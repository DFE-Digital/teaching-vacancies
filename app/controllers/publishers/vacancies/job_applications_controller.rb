require "prawn-html"

class Publishers::Vacancies::JobApplicationsController < Publishers::Vacancies::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns
  include DatesHelper
  include JobApplicationsHelper
  include QualificationsHelper

  helper_method :employments, :form, :job_applications, :qualification_form_param_key, :sort, :sorted_job_applications

  def reject
    raise ActionController::RoutingError, "Cannot reject a draft or withdrawn application" if
      job_application.draft? || job_application.withdrawn?
  end

  def shortlist
    raise ActionController::RoutingError, "Cannot shortlist a draft or withdrawn application" if
      job_application.draft? || job_application.withdrawn?
  end

  def show
    redirect_to organisation_job_job_application_withdrawn_path(vacancy.id, job_application) if job_application.withdrawn?

    raise ActionController::RoutingError, "Cannot view a draft application" if job_application.draft?

    job_application.reviewed! if job_application.submitted?
  end

  def download_pdf
    pdf = generate_pdf(job_application, vacancy)

    send_data pdf.render, filename: "job_application_#{job_application.id}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end



  def update_status
    raise ActionController::RoutingError, "Cannot shortlist or reject a draft or withdrawn application" if
      job_application.draft? || job_application.withdrawn?

    job_application.update(form_params.merge(status: status))
    Jobseekers::JobApplicationMailer.send(:"application_#{status}", job_application).deliver_later
    redirect_to organisation_job_job_applications_path(vacancy.id), success: t(".#{status}", name: job_application.name)
  end

  private

  def generate_pdf(job_application, vacancy)
    Prawn::Document.new do |pdf|
      add_headers(pdf, job_application, vacancy)
      add_personal_details(pdf, job_application)
      add_professional_status(pdf, job_application)
      add_qualifications(pdf, job_application)
      add_training_and_cpds(pdf, job_application)
      add_employment_history(pdf, job_application)
      add_personal_statement(pdf, job_application)
      add_references(pdf, job_application)
      add_ask_for_support(pdf, job_application)
      add_declarations(pdf, job_application, vacancy)
    end
  end

  def add_headers(pdf, job_application, vacancy)
    caption_text = I18n.t("jobseekers.job_applications.caption", job_title: vacancy.job_title, organisation: vacancy.organisation_name)
    pdf.text caption_text, size: 12, style: :italic
    pdf.move_down 10
    pdf.text job_application.name, size: 24, style: :bold
    pdf.move_down 20
  end

  def add_declarations(pdf, job_application, vacancy)
    pdf.move_down 50

    pdf.text "Declarations", size: 18, style: :bold
    pdf.move_down 10

    safeguarding_issues_info = job_application_safeguarding_issues_info(job_application)
    close_relationships_info = job_application_close_relationships_info(job_application)

    declarations_data = [
      [I18n.t("helpers.legend.jobseekers_job_application_declarations_form.safeguarding_issue"), safeguarding_issues_info],
      [I18n.t("helpers.legend.jobseekers_job_application_declarations_form.close_relationships", organisation: vacancy.organisation_name), close_relationships_info]
    ]

    pdf.table(declarations_data, cell_style: { borders: [] }) do
      cells.padding = 12
      cells.borders = []
      columns(0).font_style = :bold
      columns(0).align = :left
      columns(1).align = :left
      columns(0).width = 150 # Set a fixed width for the key column
    end
  end

  def job_application_close_relationships_info(job_application)
    case job_application.close_relationships
    when "yes"
      "Yes\nDetails: #{job_application.close_relationships_details}"
    when "no"
      "No"
    else
      "No information provided"
    end
  end

  def job_application_safeguarding_issues_info(job_application)
    case job_application.safeguarding_issue
    when "yes"
      "Yes\nDetails: #{job_application.safeguarding_issue_details}"
    when "no"
      "No"
    else
      "No information provided"
    end
  end

  def add_ask_for_support(pdf, job_application)
    pdf.start_new_page

    pdf.text "Ask for Support", size: 18, style: :bold
    pdf.move_down 10

    support_needed_info = job_application_support_needed_info(job_application)

    support_data = [
      [I18n.t("helpers.legend.jobseekers_job_application_ask_for_support_form.support_needed"), support_needed_info]
    ]

    pdf.table(support_data, cell_style: { borders: [] }) do
      cells.padding = 12
      cells.borders = []
      columns(0).font_style = :bold
      columns(0).align = :left
      columns(1).align = :left
      columns(0).width = 150 # Set a fixed width for the key column
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

  def add_personal_details(pdf, job_application)
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

    pdf.move_down 20
    pdf.text "Personal Details", size: 18, style: :bold
    pdf.move_down 10

    pdf.table(personal_details, cell_style: { borders: [] }) do
      cells.padding = 12
      cells.borders = []
      columns(0).font_style = :bold
      columns(0).align = :left
      columns(1).align = :left
      columns(0).width = 150
    end
  end

  def add_professional_status(pdf, job_application)
    professional_status = [
      [I18n.t("helpers.legend.jobseekers_job_application_professional_status_form.qualified_teacher_status"), job_application_qualified_teacher_status_info(job_application)],
      [I18n.t("helpers.label.jobseekers_job_application_personal_details_form.teacher_reference_number_review"), job_application_jobseeker_profile_info(job_application)],
      [I18n.t("helpers.legend.jobseekers_job_application_professional_status_form.statutory_induction_complete"), job_application.statutory_induction_complete.humanize],
    ]

    pdf.move_down 20
    pdf.text "Professional Status", size: 18, style: :bold
    pdf.move_down 10

    pdf.table(professional_status, cell_style: { borders: [] }) do
      cells.padding = 12
      cells.borders = []
      columns(0).font_style = :bold
      columns(0).align = :left  # Align keys to the left
      columns(1).align = :left  # Align values to the left
      columns(0).width = 150    # Adjust width of the key column
    end
  end

  def add_references(pdf, job_application)
    pdf.start_new_page

    pdf.text "References", size: 18, style: :bold
    pdf.move_down 10

    if job_application.references.none?
      no_references_message = if jobseeker_signed_in?
                                I18n.t("jobseekers.job_applications.review.employment_history.none")
                              elsif publisher_signed_in?
                                I18n.t("jobseekers.job_applications.show.employment_history.none")
                              end
      pdf.text no_references_message, size: 12
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

        pdf.table(reference_data, cell_style: { borders: [] }) do
          cells.padding = 12
          cells.borders = []
          columns(0).font_style = :bold
          columns(0).align = :left
          columns(1).align = :left
          columns(0).width = 150
        end
      end
    end
  end


  def add_qualifications(pdf, job_application)
    pdf.start_new_page

    pdf.move_down 20
    pdf.text "Qualifications", size: 18, style: :bold
    pdf.move_down 10

    if job_application.qualifications.none?
      no_qualifications_message = if jobseeker_signed_in?
                                    I18n.t("jobseekers.job_applications.review.qualifications.none")
                                  elsif publisher_signed_in?
                                    I18n.t("jobseekers.job_applications.show.qualifications.none")
                                  end
      pdf.text no_qualifications_message, size: 12
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

  def add_employment_history(pdf, job_application)
    pdf.move_down 50

    pdf.text "Employment History", size: 18, style: :bold
    pdf.move_down 10

    if job_application.employments.none?
      no_employment_message = if jobseeker_signed_in?
                                I18n.t("jobseekers.job_applications.review.employment_history.none")
                              elsif publisher_signed_in?
                                I18n.t("jobseekers.job_applications.show.employment_history.none")
                              end
      pdf.text no_employment_message, size: 12
    else
      job_application.employments.sort_by { |r| r[:started_on] }.reverse.each_with_index do |employment, index|
        pdf.move_down 10
        pdf.text employment.job_title, size: 14, style: :bold

        employment_data = [
          ["Organisation:", employment.organisation],
          ["Main Duties:", employment.main_duties],
          ["Started on:", employment.started_on.to_formatted_s(:month_year)],
          ["Current Role:", employment.current_role.humanize],
        ]

        if employment.subjects.present? || jobseeker_signed_in?
          employment_data << ["Subjects:", employment.subjects.presence || I18n.t("jobseekers.job_applications.not_defined")]
        end

        if employment.current_role == "no"
          employment_data << ["Ended on:", employment.ended_on.to_formatted_s(:month_year)]
        end

        employment_data << ["Reason for Leaving:", employment.reason_for_leaving] if employment.reason_for_leaving.present?

        pdf.table(employment_data, cell_style: { borders: [] }) do
          cells.padding = 12
          cells.borders = []
          columns(0).font_style = :bold
          columns(0).align = :left
          columns(1).align = :left
          columns(0).width = 150
        end

        if employment.break?
          pdf.move_down 5
          pdf.text "Employment Break", size: 12, style: :italic
          pdf.text employment.reason_for_break, size: 12
        end

        next unless (gap = job_application.unexplained_employment_gaps[employment]).present?

        pdf.move_down 5
        pdf.text "Unexplained Employment Gap", size: 12, style: :italic
        pdf.text gap, size: 12
      end
    end
  end

  def add_personal_statement(pdf, job_application)
    pdf.move_down 50
    pdf.text "Personal Statement", size: 18, style: :bold
    pdf.move_down 10

    if job_application.personal_statement.present?
      pdf.text job_application.personal_statement, size: 12, leading: 4
    else
      pdf.text I18n.t(".personal_statement.blank"), size: 12, style: :italic
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

  def add_secondary_qualification_details(pdf, qualification)
    pdf.move_down 5
    pdf.text "Secondary Qualification", size: 12, style: :italic

    secondary_qualification_data = [
      ["Name:", qualification.name],
      ["Grade:", qualification.grade],
      ["Year Awarded:", qualification.year],
    ].reject { |row| row[1].blank? }

    # Align secondary qualification details in a table
    pdf.table(secondary_qualification_data, cell_style: { borders: [] }) do
      cells.padding = 12
      cells.borders = []
      columns(0).font_style = :bold
      columns(0).align = :left
      columns(1).align = :left
      columns(0).width = 150
    end
  end

  def add_general_qualification_details(pdf, qualification)
    pdf.move_down 5

    general_qualification_data = [
      ["Qualification Name:", qualification.name],
      ["Institution:", qualification.institution],
      ["Grade:", qualification.grade],
      ["Year Awarded:", qualification.year],
    ].reject { |row| row[1].blank? }

    pdf.table(general_qualification_data, cell_style: { borders: [] }) do
      cells.padding = 12
      cells.borders = []
      columns(0).font_style = :bold
      columns(0).align = :left
      columns(1).align = :left
      columns(0).width = 150 # Set a width to ensure consistency
    end
  end

  def add_training_and_cpds(pdf, job_application)
    pdf.start_new_page
    pdf.text "Training and CPD", size: 18, style: :bold
    pdf.move_down 10

    if job_application.training_and_cpds.none?
      no_training_message = if jobseeker_signed_in?
                              I18n.t("jobseekers.job_applications.review.training_and_cpds.none")
                            elsif publisher_signed_in?
                              I18n.t("jobseekers.job_applications.show.training_and_cpds.none")
                            end
      pdf.text no_training_message, size: 12
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

  def job_applications
    @job_applications ||= vacancy.job_applications.not_draft
  end

  def sorted_job_applications
    sort.by_db_column? ? job_applications.order(sort.by => sort.order) : job_applications_sorted_by_virtual_attribute
  end

  def job_applications_sorted_by_virtual_attribute
    # When we 'order' by a virtual attribute we have to do the sorting after all scopes.
    # last_name is a virtual attribute as it is an encrypted column.
    job_applications.sort_by(&sort.by.to_sym)
  end

  def form
    @form ||= Publishers::JobApplication::UpdateStatusForm.new
  end

  def form_params
    params.require(:publishers_job_application_update_status_form).permit(:further_instructions, :rejection_reasons)
  end

  def employments
    @employments ||= job_application.employments.order(:started_on)
  end

  def status
    return "shortlisted" if form_params.key?("further_instructions")

    "unsuccessful" if form_params.key?("rejection_reasons")
  end

  def sort
    @sort ||= Publishers::JobApplicationSort.new.update(sort_by: params[:sort_by])
  end
end
