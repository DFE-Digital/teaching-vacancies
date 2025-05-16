class Publishers::Vacancies::JobApplicationsController < Publishers::Vacancies::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns
  include DatesHelper

  helper_method :job_applications

  def index
    @form = Publishers::JobApplication::TagForm.new
  end

  def show
    redirect_to organisation_job_job_application_withdrawn_path(vacancy.id, job_application) if job_application.withdrawn?

    @notes_form = Publishers::JobApplication::NotesForm.new

    raise ActionController::RoutingError, "Cannot view a draft application" if job_application.draft?

    job_application.reviewed! if job_application.submitted?
  end

  def download_pdf
    pdf = JobApplicationPdfGenerator.new(job_application).generate

    send_data(
      pdf.render,
      filename: "job_application_#{job_application.id}.pdf",
      type: "application/pdf",
      disposition: "inline",
    )
  end

  def tag_single
    prepare_to_tag([params.fetch(:id)])
  end

  def tag
    tag_params = params.require(:publishers_job_application_tag_form).permit(job_applications: [])
    if params["download_selected"] == "true"
      download_selected(tag_params)
    else
      prepare_to_tag(tag_params.fetch(:job_applications).compact_blank)
    end
  end

  def update_tag
    update_tag_params = params.require(:publishers_job_application_status_form).permit(:status, job_applications: [])

    applications = update_tag_params.fetch(:job_applications)
    new_status = update_tag_params.fetch(:status).to_sym

    JobApplication.find(applications).each do |job_application|
      job_application.update!(status: new_status)
    end
    if new_status == :interviewing
      redirect_to collect_references_organisation_job_job_applications_path(vacancy.id, job_applications: applications)
    else
      redirect_to organisation_job_job_applications_path(vacancy.id)
    end
  end

  def collect_references
    job_applications = vacancy.job_applications.find(params[:job_applications])
    @form = Publishers::JobApplication::CollectReferencesForm.new(job_applications: job_applications)
  end

  def references_and_declarations
    form_params = params.require(:publishers_job_application_collect_references_form).permit(:collect_references_and_declarations, job_applications: [])
    applications = vacancy.job_applications.find(form_params.fetch(:job_applications))
    @form = Publishers::JobApplication::CollectReferencesForm.new(form_params.merge(job_applications: applications))
    if @form.valid?
      if @form.collect_references_and_declarations
        redirect_to ask_references_email_organisation_job_job_applications_path(vacancy.id, job_applications: applications.map(&:id))
      else
        redirect_to organisation_job_job_applications_path(vacancy.id, anchor: :interviewing)
      end
    else
      render :collect_references
    end
  end

  def ask_references_email
    job_applications = vacancy.job_applications.find(params[:job_applications])
    @form = Publishers::JobApplication::ReferencesContactApplicantForm.new(job_applications: job_applications)
  end

  def references_contact_reply
    form_params = params.require(:publishers_job_application_references_contact_applicant_form).permit(:contact_applicants, job_applications: [])
    applications = vacancy.job_applications.find(form_params.fetch(:job_applications))
    @form = Publishers::JobApplication::ReferencesContactApplicantForm.new(form_params.merge(job_applications: applications))
    if @form.valid?
      applications.each do |job_application|
        Publishers::CollectReferencesMailer.inform_applicant_about_references(job_application).deliver_later if @form.contact_applicants
        job_application.referees.each do |referee|
          reference = referee.create_job_reference!(token: SecureRandom.uuid)
          Publishers::CollectReferencesMailer.collect_references(reference).deliver_later
        end
      end
      redirect_to organisation_job_job_applications_path(vacancy.id, anchor: :interviewing)
    else
      render :ask_references_email
    end
  end

  def withdrawn; end

  def pre_interview_checks
    @references = job_application.referees.map(&:job_reference)
  end

  private

  def prepare_to_tag(job_applications)
    @form = Publishers::JobApplication::TagForm.new(job_applications: job_applications)
    if @form.valid?
      @job_applications = vacancy.job_applications.where(id: @form.job_applications)
      render "tag"
    else
      render "index"
    end
  end

  require "zip"

  def download_selected(tag_params)
    @form = Publishers::JobApplication::DownloadForm.new(job_applications: tag_params.fetch(:job_applications).compact_blank)
    if @form.valid?
      downloads = JobApplication
                    .includes([:qualifications, :employments, :training_and_cpds, :referees, { jobseeker: :jobseeker_profile }, { vacancy: %i[organisations publisher_organisation] }])
                    .where(vacancy: vacancy.id, id: @form.job_applications)
      stringio = Zip::OutputStream.write_buffer do |zio|
        downloads.each do |job_application|
          zio.put_next_entry "#{job_application.first_name}_#{job_application.last_name}.pdf"
          zio.write JobApplicationPdfGenerator.new(job_application).generate.render
        end
      end
      send_data(stringio.string,
                filename: "applications_#{vacancy.job_title}.zip",
                type: "application/zip")
    else
      render "index"
    end
  end

  def job_applications
    @job_applications ||= vacancy.job_applications.not_draft
  end

  def job_applications_sorted_by_virtual_attribute
    # When we 'order' by a virtual attribute we have to do the sorting after all scopes.
    # last_name is a virtual attribute as it is an encrypted column.
    job_applications.sort_by(&sort.by.to_sym)
  end
end
