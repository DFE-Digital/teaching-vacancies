class Publishers::Vacancies::JobApplicationsController < Publishers::Vacancies::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns
  include DatesHelper

  helper_method :job_applications

  before_action :set_job_application, only: %i[show download_pdf]

  def index
    @form = Publishers::JobApplication::TagForm.new
  end

  def show
    redirect_to organisation_job_job_application_withdrawn_path(vacancy.id, @job_application) if @job_application.withdrawn?

    @notes_form = Publishers::JobApplication::NotesForm.new

    raise ActionController::RoutingError, "Cannot view a draft application" if @job_application.draft?

    @job_application.reviewed! if @job_application.submitted?
  end

  def download_pdf
    pdf = JobApplicationPdfGenerator.new(@job_application).generate

    send_data(
      pdf.render,
      filename: "job_application_#{@job_application.id}.pdf",
      type: "application/pdf",
      disposition: "inline",
    )
  end

  def tag_single
    prepare_to_tag([params.fetch(:id)], "all")
  end

  def tag
    tag_params = params.require(:publishers_job_application_tag_form).permit(:origin, job_applications: [])
    if params["download_selected"] == "true"
      download_selected(tag_params)
    else
      origin = tag_params[:origin]
      prepare_to_tag(tag_params.fetch(:job_applications).compact_blank, origin)
    end
  end

  def update_tag
    update_tag_params = params.require(:publishers_job_application_status_form).permit(:origin, :status, job_applications: [])

    JobApplication.find(update_tag_params.fetch(:job_applications)).each do |job_application|
      job_application.update!(status: update_tag_params.fetch(:status))
    end
    redirect_to organisation_job_job_applications_path(vacancy.id, anchor: update_tag_params[:origin])
  end

  def withdrawn; end

  private

  def prepare_to_tag(job_applications, origin)
    @form = Publishers::JobApplication::TagForm.new(job_applications: job_applications)
    if @form.valid?
      @job_applications = vacancy.job_applications.where(id: @form.job_applications)
      @origin = origin
      render "tag"
    else
      flash[origin.to_sym] = @form.errors.full_messages
      redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
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
