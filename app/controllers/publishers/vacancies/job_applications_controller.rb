class Publishers::Vacancies::JobApplicationsController < Publishers::Vacancies::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns
  include DatesHelper

  before_action :set_job_application, only: %i[show download_pdf download_application_form pre_interview_checks collect_references]

  before_action :set_job_applications, only: %i[index tag]

  def index
    @form = Publishers::JobApplication::TagForm.new
    @tabs_data = VacancyTabsPresenter.tabs_data(vacancy)
  end

  def show
    redirect_to organisation_job_job_application_terminal_path(vacancy.id, @job_application) if @job_application.terminal_status?

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
      case params["target"]
      when "download" then download_selected(form.job_applications)
      when "export"   then export_selected(form.job_applications)
      when "emails"   then copy_emails_selected(form.job_applications)
      when "declined" then render_declined_form(form.job_applications, form.origin)
      else # when "update_status"
        render "tag"
      end
    end
  end

  def update_tag
    with_valid_tag_form(validate_status: true) do |form|
      case form.status
      when "interviewing" then redirect_to_references_and_self_disclosure(form.job_applications)
      when "offered"      then render_offered_form(form.job_applications, form.origin)
      else
        form.job_applications.each { it.update!(form.attributes) }
        redirect_to organisation_job_job_applications_path(vacancy.id, anchor: form.origin)
      end
    end
  end

  def offer
    with_valid_tag_form do |form|
      form.job_applications.find_each { it.update!(form.attributes) }
      redirect_to organisation_job_job_applications_path(vacancy.id, anchor: form.origin)
    end
  end

  def collect_references
    batch = JobApplicationBatch.create!(vacancy: vacancy)
    batch.batchable_job_applications.create!(job_application: @job_application)

    redirect_to organisation_job_job_application_batch_references_and_self_disclosure_path(vacancy.id, batch.id, Wicked::FIRST_STEP)
  end

  def terminal; end

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
                    .permit(:origin, :status, :offered_at, :declined_at, { job_applications: [] })
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
    case form.errors.details
    in { status: }      then render "tag"
    in { offered_at: }  then render "offered_date"
    in { declined_at: } then render "declined_date"
    else
      flash[form.origin] = form.errors.full_messages
      redirect_to organisation_job_job_applications_path(vacancy.id, anchor: form.origin)
    end
  end

  require "zip"

  def download_selected(job_applications)
    zip_data = JobApplicationZipBuilder.new(vacancy:, job_applications:).generate

    send_data(
      zip_data.string,
      filename: "applications_#{vacancy.job_title.parameterize}.zip",
      type: "application/zip",
    )
  end

  def export_selected(selection)
    headers = %i[first_name last_name street_address city postcode phone_number email_address national_insurance_number teacher_reference_number]

    data = CSV.generate do |csv|
      csv << headers
      selection.pluck(*headers).each { csv << it }
    end
    send_data(data, filename: "applications_offered_#{vacancy.job_title}.csv")
  end

  def copy_emails_selected(selection)
    send_data(selection.pluck(:email_address).to_json, filename: "applications_emails_#{vacancy.job_title}.json")
  end

  def redirect_to_references_and_self_disclosure(job_applications)
    batch = JobApplicationBatch.create!(vacancy: vacancy)
    job_applications.each do |ja|
      batch.batchable_job_applications.create!(job_application: ja)
    end
    redirect_to organisation_job_job_application_batch_references_and_self_disclosure_path(vacancy.id, batch.id, Wicked::FIRST_STEP)
  end

  def render_declined_form(job_applications, origin)
    @form = Publishers::JobApplication::TagForm.new(job_applications:, origin:, status: "declined")
    render "declined_date"
  end

  def render_offered_form(job_applications, origin)
    @form = Publishers::JobApplication::TagForm.new(job_applications:, origin:, status: "offered")
    render "offered_date"
  end
end
