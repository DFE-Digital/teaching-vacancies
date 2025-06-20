require "zip"

class Publishers::Vacancies::JobApplicationsController < Publishers::Vacancies::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns
  include DatesHelper

  before_action :set_job_application, only: %i[show download_pdf pre_interview_checks collect_references]

  before_action :set_job_applications, only: %i[index tag_single tag]

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
    prepare_to_tag([params.fetch(:id)], JobApplicationsHelper::JOB_APPLICATION_DISPLAYED_STATUSES.first)
  end

  def tag
    tag_params = params.require(:publishers_job_application_tag_form).permit(:origin, job_applications: [])
    origin = tag_params[:origin]
    job_applications = tag_params[:job_applications].compact_blank

    case params["target"]
    when "download" then download_selected(tag_params, origin)
    when "export"   then export_selected(tag_params, origin)
    when "emails"   then copy_emails_selected(tag_params, origin)
    when "declined" then capture_decline_date(job_applications)
    else # when "update_status"
      prepare_to_tag(job_applications, origin)
    end
  end

  def update_tag
    update_tag_params = params.require(:publishers_job_application_status_form).permit(:origin, :status, job_applications: [])
    applications = update_tag_params.fetch(:job_applications)
    origin = update_tag_params[:origin]
    status = update_tag_params[:status]

    case status
    when nil            then error_no_new_status_seleceted(applications, origin)
    when "interviewing" then start_references_and_declaration(applications)
    when "offered"      then capture_offer_date(applications)
    else
      JobApplication.find(applications).each { it.update!(status:) }
      redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
    end
  end

  def collect_references
    batch = JobApplicationBatch.create!(vacancy: vacancy)
    batch.batchable_job_applications.create!(job_application: @job_application)

    redirect_to organisation_job_job_application_batch_references_and_declaration_path(vacancy.id, batch.id, Wicked::FIRST_STEP)
  end

  def withdrawn; end

  def pre_interview_checks
    @reference_requests = @job_application.referees.filter_map(&:reference_request)
  end

  def update_all


  end

  private

  def set_job_applications
    @current_organisation = current_organisation
    @vacancy = vacancy
    @job_applications = vacancy.job_applications.not_draft
  end

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

  def error_no_new_status_seleceted(applications, origin)
    query_params = {
      publishers_job_application_tag_form: {
        origin: origin,
        job_applications: applications,
      },
    }
    flash[:error] = "You must select an option"
    redirect_to tag_organisation_job_job_applications_path(vacancy.id, query_params)
  end

  def start_references_and_declaration(applications)
    batch = JobApplicationBatch.create!(vacancy: vacancy)
    JobApplication.find(applications).each do |ja|
      batch.batchable_job_applications.create!(job_application: ja)
    end
    redirect_to organisation_job_job_application_batch_references_and_declaration_path(vacancy.id, batch.id, Wicked::FIRST_STEP)
  end

  def capture_offer_date(applications)
    job_applications = JobApplication.where(vacancy: vacancy.id, id: applications)
    @form = Publishers::JobApplication::OfferDateForm.new(job_applications:)
    render "offer_date"
  end

  def capture_decline_date(applications)
    # # copy params and status declined
    # params[:publishers_job_application_status_form] = { origin:, job_applications:, status: "declined" }
    # update_tag

    @job_applications = JobApplication.where(vacancy: vacancy.id, id: applications)
    render "decline_date"
  end

  def send_data_when_selection_valid(tag_params, origin, filename)
    @form = Publishers::JobApplication::DownloadForm.new(job_applications: tag_params.fetch(:job_applications).compact_blank)
    if @form.valid?
      data = yield JobApplication.where(vacancy: vacancy.id, id: @form.job_applications)
      send_data(data, filename:)
    else
      flash[origin.to_sym] = @form.errors.full_messages
      redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
    end
  end

  def download_selected(tag_params, origin)
    args = [tag_params, origin, "applications_#{vacancy.job_title}.zip"]
    send_data_when_selection_valid(*args) do |selection|
      downloads = selection
                    .includes([:qualifications, :employments, :training_and_cpds, :referees, { jobseeker: :jobseeker_profile }, { vacancy: %i[organisations publisher_organisation] }])

      stringio = Zip::OutputStream.write_buffer do |zio|
        downloads.each do |job_application|
          zio.put_next_entry "#{job_application.first_name}_#{job_application.last_name}.pdf"
          zio.write JobApplicationPdfGenerator.new(job_application).generate.render
        end
      end
      stringio.string
    end
  end

  def export_selected(tag_params, origin)
    args = [tag_params, origin, "applications_offered_#{vacancy.job_title}.csv"]
    send_data_when_selection_valid(*args) do |selection|
      headers = %i[first_name last_name street_address city postcode phone_number email_address national_insurance_number teacher_reference_number]

      CSV.generate do |csv|
        csv << headers
        selection.pluck(*headers).each { csv << it }
      end
    end
  end

  def copy_emails_selected(tag_params, origin)
    args = [tag_params, origin, "applications_emails_#{vacancy.job_title}.json"]
    send_data_when_selection_valid(*args) do |selection|
      selection.pluck(:email_address).to_json
    end
  end
end
