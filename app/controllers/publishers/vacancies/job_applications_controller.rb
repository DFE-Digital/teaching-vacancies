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

  def index
    @form = Publishers::JobApplication::TagForm.new
  end

  def show
    redirect_to organisation_job_job_application_withdrawn_path(vacancy.id, job_application) if job_application.withdrawn?

    raise ActionController::RoutingError, "Cannot view a draft application" if job_application.draft?

    job_application.reviewed! if job_application.submitted?
  end

  def download_pdf
    pdf = JobApplicationPdfGenerator.new(job_application, vacancy).generate

    send_data(
      pdf.render,
      filename: "job_application_#{job_application.id}.pdf",
      type: "application/pdf",
      disposition: "inline",
    )
  end

  def update_status
    raise ActionController::RoutingError, "Cannot shortlist or reject a draft or withdrawn application" if
      job_application.draft? || job_application.withdrawn?

    job_application.update(form_params.merge(status: status))
    Jobseekers::JobApplicationMailer.send(:"application_#{status}", job_application).deliver_later
    redirect_to organisation_job_job_applications_path(vacancy.id), success: t(".#{status}", name: job_application.name)
  end

  def tag
    tag_params = params.require(:publishers_job_application_tag_form).permit(job_applications: [])
    @form = Publishers::JobApplication::TagForm.new(tag_params.merge(job_applications: tag_params.fetch(:job_applications).compact_blank))
    if @form.valid?
      if params["download_selected"] == "true"
        downloads = JobApplication
                      .includes([:qualifications, :employments, :training_and_cpds, :references, { jobseeker: :jobseeker_profile }, {vacancy: [:organisations, :publisher_organisation]}])
                      .where(vacancy: vacancy.id)
                      .select { |job_application| @form.job_applications.include?(job_application.id) }
        download_selected downloads
      else
        @job_applications = vacancy.job_applications.where(id: @form.job_applications)
        render "tag"
      end
    else
      render "index"
    end
  end

  def update_tag
    form_params = params.require(:publishers_job_application_status_form).permit(:status, job_applications: [])

    JobApplication.find(form_params.fetch(:job_applications)).each do |job_application|
      job_application.update!(status: form_params.fetch(:status))
    end
    redirect_to organisation_job_job_applications_path(vacancy.id)
  end

  private

  require "zip"

  def download_selected downloads
    stringio = Zip::OutputStream.write_buffer do |zio|
      downloads.each do |job_application|
        zio.put_next_entry "#{job_application.first_name}_#{job_application.last_name}.pdf"
        pdf = JobApplicationPdfGenerator.new(job_application, vacancy).generate
        zio.write pdf.render
      end
    end
    send_data(
      stringio.string,
      filename: "applications_#{vacancy.job_title}.zip",
      type: "application/zip",
      # disposition: "inline",
      )
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
