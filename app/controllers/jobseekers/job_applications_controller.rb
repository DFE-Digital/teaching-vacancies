# rubocop:disable Metrics/ClassLength
class Jobseekers::JobApplicationsController < Jobseekers::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns
  include JobApplicationsPdfHelper

  before_action :set_job_application, only: %i[review apply pre_submit submit post_submit show confirm_destroy destroy confirm_withdraw withdraw download]

  before_action :raise_cannot_apply, unless: -> { vacancy.allow_job_applications? }, only: %i[new create]
  before_action :redirect_if_job_application_exists, only: %i[new create]
  before_action :redirect_unless_draft_job_application, only: %i[review]

  helper_method :employments, :job_application, :qualification_form_param_key, :vacancy

  # rubocop:disable Metrics/AbcSize
  def index
    # only show applications from the last 12 months to avoid cluttering up the display
    default_scope = JobApplication.includes(:self_disclosure_request, :vacancy)
                                  .within_jobseeker_retention_period
                                  .where(jobseeker: current_jobseeker)
    draft_job_applications = default_scope.draft.order(updated_at: :desc)
    active_drafts, expired_drafts = draft_job_applications.partition { |job_application| job_application.vacancy.expires_at.future? }

    # This is the primary sort order for application statuses on the index page
    status_keys = %i[offered interviewing shortlisted reviewed submitted unsuccessful rejected unsuccessful_interview withdrawn declined].freeze

    action_required = default_scope
                        .joins(:self_disclosure_request)
                        .merge(SelfDisclosureRequest.sent)
                        .interviewing.order(submitted_at: :desc)

    active_job_applications = default_scope.where.not(status: :draft)
                                                .order(submitted_at: :desc)
                                                .sort_by { |x| status_keys.index(x.status.to_sym) } - action_required
    all_applications = active_drafts + action_required + active_job_applications + expired_drafts

    @count = all_applications.size
    @pagy, @job_applications = pagy_array(all_applications)
  end
  # rubocop:enable Metrics/AbcSize

  def new
    send_dfe_analytics_event
    if session[:newly_created_user]
      @newly_created_user = true
      session.delete(:newly_created_user)
    end

    @has_previous_application = nil
    if quick_apply?
      # If we don't know the user's status, or they have the right perform the role
      # then we can send them straight to the 'quick apply' screen, otherwise we display the
      # (badly named) about_your_application screen which suggests they might not be qualified for the role.
      if !vacancy.visa_sponsorship_available? && profile.present? && profile.needs_visa_for_uk?
        render "about_your_application"
      else
        @has_previous_application = previous_application?
      end
    end
    if session[:user_exists_first_log_in]
      @user_exists_first_log_in = true
      session.delete(:user_exists_first_log_in)
    end
  end

  def create
    if quick_apply?
      new_job_application = prefill_job_application_with_available_data

      redirect_to jobseekers_job_application_apply_path(new_job_application), notice: t("jobseekers.job_applications.new.import_from_previous_application")
    else
      new_job_application = vacancy.create_job_application_for(current_jobseeker)
      redirect_to jobseekers_job_application_apply_path(new_job_application.id)
    end
  end

  def pre_submit
    @form = Jobseekers::JobApplication::PreSubmitForm.new(completed_steps: job_application.completed_steps, all_steps: step_process.validatable_steps)
    if @form.valid? && all_steps_valid?
      redirect_to jobseekers_job_application_review_path(@job_application)
    else
      render :apply
    end
  end

  def review
    session[:back_to_review] = (session[:back_to_review] || []).push(job_application.id).uniq
    @review_form = Jobseekers::JobApplication::ReviewForm.new
  end

  def apply
    @form = Jobseekers::JobApplication::PreSubmitForm.new(
      completed_steps: job_application.completed_steps,
      all_steps: step_process.validatable_steps,
    )
  end

  def submit
    raise ActionController::RoutingError, "Cannot submit application for non-listed job" unless vacancy.live?
    raise ActionController::RoutingError, "Cannot submit non-draft application" unless job_application.draft?

    @review_form = Jobseekers::JobApplication::ReviewForm.new(review_form_params)
    if @review_form.valid? && all_steps_valid?
      update_jobseeker_profile!(job_application) if @review_form.update_profile
      job_application.submit!
      redirect_to jobseekers_job_application_post_submit_path job_application
    else
      render :review
    end
  end

  def post_submit
    @application_feedback_form = Jobseekers::JobApplication::FeedbackForm.new
  end

  def show
    raise ActionController::RoutingError, "Cannot view draft application" if job_application.draft?

    if params[:tab] == "messages"
      @tab = "messages"
      @show_form = params[:show_form]
      conversation = job_application.conversations.first
      @messages = (conversation && conversation.messages.order(created_at: :desc)) || []
      @message_form = Publishers::JobApplication::MessagesForm.new

      # Mark publisher messages as read when jobseeker views them
      publisher_messages = @messages.select { |msg| msg.is_a?(PublisherMessage) && msg.unread? }
      publisher_messages.each(&:mark_as_read!)
    end
  end

  def download
    document = submitted_application_form(job_application)
    send_data(document.data, filename: document.filename, disposition: "inline")
  end

  def confirm_destroy
    raise ActionController::RoutingError, "Cannot delete non-draft application" unless job_application.draft?
  end

  def destroy
    raise ActionController::RoutingError, "Cannot delete non-draft application" unless job_application.draft?

    job_application.destroy
    redirect_to jobseekers_job_applications_path,
                success: t("messages.jobseekers.job_applications.draft_deleted", job_title: vacancy.job_title)
  end

  def confirm_withdraw
    raise ActionController::RoutingError, "Cannot withdraw application in this state" unless job_application.can_be_withdrawn?

    @withdraw_form = Jobseekers::JobApplication::WithdrawForm.new
  end

  def withdraw
    raise ActionController::RoutingError, "Cannot withdraw application in this state" unless job_application.can_be_withdrawn?

    @withdraw_form = Jobseekers::JobApplication::WithdrawForm.new(withdraw_form_params)

    if @withdraw_form.valid?
      job_application.withdrawn!
      redirect_to jobseekers_job_applications_path, success: t(".success", job_title: vacancy.job_title)
    else
      render :confirm_withdraw
    end
  end

  private

  attr_reader :job_application

  def prefill_job_application_with_available_data
    Jobseekers::JobApplications::QuickApply.new(current_jobseeker, vacancy).job_application
  end

  def update_jobseeker_profile!(job_application)
    profile = job_application.jobseeker.jobseeker_profile
    return unless profile.present?

    profile.replace_qualifications!(job_application.qualifications)
    profile.replace_employments!(job_application.employments)
    profile.replace_training_and_cpds!(job_application.training_and_cpds)
    profile.replace_memberships!(job_application.professional_body_memberships)
  end

  def all_steps_valid?
    # Check that all steps are valid, in case we have changed the validations since the step was completed.
    # NB: Only validates top-level step forms. Does not validate individual qualifications, employments, or references.
    step_process.validatable_steps.all? { |step| step_valid?(step) }
  end

  def step_valid?(step)
    form_class = step_process.form_class_for(step)
    attributes = form_class.load_form(job_application)
    form = form_class.new(attributes)

    form.valid?.tap { job_application.errors.merge!(form.errors) }
  end

  def employments
    @employments ||= job_application.employments.order(:started_on)
  end

  def set_job_application
    @job_application = current_jobseeker.job_applications.find(params[:job_application_id] || params[:id])
  end

  def redirect_if_job_application_exists
    job_application = current_jobseeker.job_applications.find_by(vacancy_id: vacancy.id)
    return unless job_application

    if job_application.draft?
      redirect_to jobseekers_job_applications_path,
                  warning: t("messages.jobseekers.job_applications.already_exists.draft_html",
                             job_title: vacancy.job_title,
                             link: jobseekers_job_application_review_path(job_application))
    else
      redirect_to jobseekers_job_applications_path,
                  warning: t("messages.jobseekers.job_applications.already_exists.submitted",
                             job_title: vacancy.job_title)
    end
  end

  def redirect_unless_draft_job_application
    job_application = current_jobseeker.job_applications.find_by(vacancy_id: vacancy.id)
    return unless job_application

    redirect_to jobseekers_job_application_path(job_application), warning: t(".warning") unless job_application.draft?
  end

  def raise_cannot_apply
    raise ActionController::RoutingError, "Cannot apply for this vacancy"
  end

  def review_form_params
    params.expect(jobseekers_job_application_review_form: [:confirm_data_accurate, :confirm_data_usage, { update_profile: [] }])
          .merge(completed_steps: job_application.completed_steps, all_steps: step_process.validatable_steps)
  end

  def withdraw_form_params
    (params[:jobseekers_job_application_withdraw_form] || params).permit(:withdraw_reason)
  end

  def vacancy
    @vacancy ||= if params[:job_id].present?
                   PublishedVacancy.live.find(params[:job_id])
                 else
                   job_application.vacancy
                 end
  end

  def send_dfe_analytics_event
    fail_safe do
      event = DfE::Analytics::Event.new
                                   .with_type(:vacancy_apply_clicked)
                                   .with_request_details(request)
                                   .with_response_details(response)
                                   .with_user(current_jobseeker)
                                   .with_data(data: { vacancy_id: vacancy.id })

      DfE::Analytics::SendEvents.do([event])
    end
  end

  def profile
    @profile ||= current_jobseeker.jobseeker_profile
  end
  helper_method :profile

  def previous_application?
    current_jobseeker.has_submitted_native_job_application?
  end

  def quick_apply?
    previous_application? || profile.present?
  end
end
# rubocop:enable Metrics/ClassLength
