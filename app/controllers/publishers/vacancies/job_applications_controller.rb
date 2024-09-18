class Publishers::Vacancies::JobApplicationsController < Publishers::Vacancies::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns
  include DatesHelper

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
    Prawn::Document.new do
      caption_text = I18n.t("jobseekers.job_applications.caption", job_title: vacancy.job_title, organisation: vacancy.organisation_name)
      text caption_text, size: 12, style: :italic  # Adjust size and style to match GovUK caption

      # Add some spacing (similar to margins in HTML)
      move_down 10

      # Heading (h1.govuk-heading-xl equivalent)
      text job_application.name, size: 24, style: :bold  # Adjust size to match heading-xl, bold style for heading

      # Add more space after heading if needed
      move_down 20
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
