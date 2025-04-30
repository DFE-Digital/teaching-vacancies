class Publishers::Vacancies::JobApplicationsController < Publishers::Vacancies::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns
  include DatesHelper

  helper_method :employments, :form, :job_applications, :qualification_form_param_key, :job_application_by_status

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

    @notes_form = Publishers::JobApplication::NotesForm.new

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

  def tag_single
    prepare_to_tag([params.fetch(:id)])
  end

  def tag
    tag_params = params.require(:publishers_job_application_tag_form).permit(:origin, job_applications: [])
    if params["download_selected"] == "true"
      download_selected(tag_params)
    else
      prepare_to_tag(tag_params.fetch(:job_applications).compact_blank, tag_params[:origin])
    end
  end

  def update_tag
    update_tag_params = params.require(:publishers_job_application_status_form).permit(:origin, :status, job_applications: [])

    JobApplication.find(update_tag_params.fetch(:job_applications)).each do |job_application|
      job_application.update!(status: update_tag_params.fetch(:status))
    end
    redirect_to organisation_job_job_applications_path(
      vacancy.id,
      anchor: current_tab(update_tag_params[:origin]),
    )
  end

  private

  # :nocov:
  def current_tab(origin)
    case origin.to_sym
    when :new
      [:new, job_application_by_status[:new].count]
    when :unsuccessful
      ["not-considering", job_application_by_status[:unsuccessful].count]
    when :shortlisted
      [:shortlisted, job_application_by_status[:shortlisted].count]
    when :interviewing
      [:interviewing, job_application_by_status[:interviewing].count]
    else
      []
    end.join("-")
  end
  # :nocov:

  def prepare_to_tag(job_applications, origin)
    @form = Publishers::JobApplication::TagForm.new(job_applications: job_applications)
    if @form.valid?
      @job_applications = vacancy.job_applications.where(id: @form.job_applications)
      @origin = origin
      render "tag"
    else
      flash[origin.to_sym] = @form.errors.full_messages
      redirect_to organisation_job_job_applications_path(
        vacancy.id,
        anchor: current_tab(origin),
      )
    end
  end

  require "zip"

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # :nocov:
  def download_selected(tag_params)
    @form = Publishers::JobApplication::DownloadForm.new(job_applications: tag_params.fetch(:job_applications).compact_blank)
    if @form.valid?
      downloads = JobApplication
                    .includes([:qualifications, :employments, :training_and_cpds, :references, { jobseeker: :jobseeker_profile }, { vacancy: %i[organisations publisher_organisation] }])
                    .where(vacancy: vacancy.id, id: @form.job_applications)
      stringio = Zip::OutputStream.write_buffer do |zio|
        downloads.each do |job_application|
          zio.put_next_entry "#{job_application.first_name}_#{job_application.last_name}.pdf"
          zio.write JobApplicationPdfGenerator.new(job_application, vacancy).generate.render
        end
      end
      send_data(stringio.string,
                filename: "applications_#{vacancy.job_title}.zip",
                type: "application/zip")
    else
      origin = tag_params[:origin].to_sym
      flash[origin] = @form.errors.full_messages
      redirect_to organisation_job_job_applications_path(
        vacancy.id,
        anchor: current_tab(origin),
      )
    end
  end
  # :nocov:
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def job_applications
    @job_applications ||= vacancy.job_applications.not_draft
  end

  def job_application_by_status
    @job_application_by_status ||= job_applications.group_by_status
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
end
