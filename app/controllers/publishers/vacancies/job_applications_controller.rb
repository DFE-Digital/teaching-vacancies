class Publishers::Vacancies::JobApplicationsController < Publishers::Vacancies::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns
  include DatesHelper

  before_action :set_job_application, only: %i[show download_pdf download_application_form pre_interview_checks collect_references]

  before_action :set_job_applications, only: %i[index tag]

  def index
    @form = Publishers::JobApplication::TagForm.new

    @candidates = JobApplication.statuses.transform_values do |status_idx|
      vacancy.job_applications.where(status: status_idx)
    end

    @candidates["submitted"] = vacancy.job_applications.where(status: %i[submitted reviewed])
    @candidates["unsuccessful"] = vacancy.job_applications.where(status: %i[unsuccessful withdrawn])

    @tab_headers = %w[submitted unsuccessful shortlisted interviewing].map do |tab_name|
      [tab_name, @candidates[tab_name].count]
    end
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

  def download_application_form
    unless @job_application.application_form.attached?
      redirect_to organisation_job_job_application_path(vacancy.id, @job_application.id), alert: I18n.t("publishers.vacancies.job_applications.download_pdf.no_file")
      return
    end

    send_data(
      @job_application.application_form.download,
      filename: @job_application.application_form.filename.to_s,
      type: @job_application.application_form.content_type,
      disposition: "inline",
    )
  end

  def tag
    with_valid_tag_form do |form|
      if params["target"] == "download"
        download_selected(form.job_applications)
      else # when "update_status"
        render "tag"
      end
    end
  end

  def update_tag
    with_valid_tag_form(validate_status: true) do |form|
      if form.status == "interviewing"
        batch = JobApplicationBatch.create!(vacancy: vacancy)
        form.job_applications.each { |ja| batch.batchable_job_applications.create!(job_application: ja) }
        redirect_to organisation_job_job_application_batch_references_and_self_disclosure_path(vacancy.id, batch.id, Wicked::FIRST_STEP)
      else
        form.job_applications.each { |ja| ja.update!(status: form.status) }
        redirect_to organisation_job_job_applications_path(vacancy.id, anchor: form.origin)
      end
    end
  end

  def collect_references
    batch = JobApplicationBatch.create!(vacancy: vacancy)
    batch.batchable_job_applications.create!(job_application: @job_application)

    redirect_to organisation_job_job_application_batch_references_and_self_disclosure_path(vacancy.id, batch.id, Wicked::FIRST_STEP)
  end

  def withdrawn; end

  def pre_interview_checks
    @reference_requests = @job_application.referees.filter_map(&:reference_request)
  end

  private

  def set_job_applications
    @current_organisation = current_organisation
    @vacancy = vacancy
    @job_applications = vacancy.job_applications.not_draft
  end

  def with_valid_tag_form(validate_status: false)
    form_class = Publishers::JobApplication::TagForm
    form_params = params
                    .fetch(ActiveModel::Naming.param_key(form_class), {})
                    .permit(:origin, :status, { job_applications: [] })
    form_params[:job_applications] = vacancy.job_applications.where(id: Array(form_params[:job_applications]).compact_blank)
    form_params[:validate_status] = validate_status

    @form = form_class.new(form_params)
    if @form.valid?
      yield @form
    else
      handle_tag_form_errors(@form)
    end
  end

  def handle_tag_form_errors(form)
    if form.errors.details.key?(:status)
      render "tag"
    else
      flash[form.origin] = form.errors.full_messages
      redirect_to organisation_job_job_applications_path(vacancy.id, anchor: form.origin)
    end
  end

  require "zip"

  def download_selected(job_applications)
    zip_data = JobApplicationZipBuilder.new(vacancy: vacancy, job_applications: job_applications).generate

    send_data(
      zip_data.string,
      filename: "applications_#{vacancy.job_title.parameterize}.zip",
      type: "application/zip",
    )
  end
end
