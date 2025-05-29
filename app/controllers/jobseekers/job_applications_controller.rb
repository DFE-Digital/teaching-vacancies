# rubocop:disable Metrics/ClassLength
class Jobseekers::JobApplicationsController < Jobseekers::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns

  before_action :set_job_application, only: %i[review apply pre_submit submit post_submit show confirm_destroy destroy confirm_withdraw withdraw]
  before_action :raise_unless_vacancy_enable_job_applications,
                :redirect_if_job_application_exists, only: %i[new create new_quick_apply quick_apply]
  before_action :redirect_unless_draft_job_application, only: %i[review]

  helper_method :employments, :job_application, :qualification_form_param_key, :review_form, :vacancy, :withdraw_form

  def new
    send_dfe_analytics_event
    if session[:newly_created_user]
      @newly_created_user = true
      session.delete(:newly_created_user)
    end

    if quick_apply?
      redirect_to about_your_application_jobseekers_job_job_application_path(vacancy.id)
    elsif session[:user_exists_first_log_in]
      @user_exists_first_log_in = true
      session.delete(:user_exists_first_log_in)
    end
  end

  def create
    new_job_application = if vacancy.has_uploaded_form?
                            current_jobseeker.uploaded_job_applications.create!(vacancy:)
                          else
                            current_jobseeker.native_job_applications.create!(vacancy:)
                          end

    redirect_to jobseekers_job_application_apply_path(new_job_application.id)
  end

  def pre_submit
    @form = Jobseekers::JobApplication::PreSubmitForm.new(completed_steps: job_application.completed_steps, all_steps: all_steps)
    if @form.valid? && all_steps_valid?
      redirect_to jobseekers_job_application_review_path(@job_application)
    else
      render :apply
    end
  end

  def review
    session[:back_to_review] = (session[:back_to_review] || []).push(job_application.id).uniq
  end

  # This redirect happens if we don't know the user's status, or they have the right perform the role
  # (either they have a visa or the job doesn't require one)
  def about_your_application
    if profile&.personal_details.nil? || profile.personal_details.has_right_to_work_in_uk? || vacancy.visa_sponsorship_available?
      redirect_to new_quick_apply_jobseekers_job_job_application_path(vacancy.id)
    end
  end

  def new_quick_apply
    if session[:user_exists_first_log_in]
      @user_exists_first_log_in = true
      session.delete(:user_exists_first_log_in)
    end

    @has_previous_application = previous_application?
    raise ActionController::RoutingError, "Cannot quick apply if there's no profile or non-draft applications" unless quick_apply?
  end

  def apply
    @form = Jobseekers::JobApplication::PreSubmitForm.new(
      completed_steps: job_application.completed_steps,
      all_steps: all_steps,
    )
  end

  def quick_apply
    raise ActionController::RoutingError, "Cannot quick apply if there's no profile or non-draft applications" unless quick_apply?

    new_job_application = prefill_job_application_with_available_data

    redirect_to jobseekers_job_application_apply_path(new_job_application), notice: t("jobseekers.job_applications.new_quick_apply.import_from_previous_application")
  end

  def submit
    raise ActionController::RoutingError, "Cannot submit application for non-listed job" unless vacancy.listed?
    raise ActionController::RoutingError, "Cannot submit non-draft application" unless job_application.draft?

    if review_form.valid? && all_steps_valid?
      update_jobseeker_profile!(job_application) if review_form.update_profile
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
    raise ActionController::RoutingError, "Cannot withdraw non-reviewed/shortlisted/submitted application" unless
      job_application.status.in?(%w[reviewed shortlisted submitted])
  end

  def withdraw
    raise ActionController::RoutingError, "Cannot withdraw non-reviewed/shortlisted/submitted application" unless
      job_application.status.in?(%w[reviewed shortlisted submitted])

    if withdraw_form.valid?
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
    Jobseekers::JobApplications::JobApplicationHandler.new(job_application, step_process).all_steps_valid?
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

  def raise_unless_vacancy_enable_job_applications
    raise ActionController::RoutingError, "Cannot apply for this vacancy" unless vacancy.uses_either_native_or_uploaded_job_application_form?
  end

  def review_form
    @review_form ||= Jobseekers::JobApplication::ReviewForm.new(form_attributes)
  end

  def withdraw_form
    @withdraw_form ||= Jobseekers::JobApplication::WithdrawForm.new(form_attributes)
  end

  def form_attributes
    case action_name
    when "review", "confirm_withdrawn"
      {}
    when "submit"
      review_form_params
    when "withdraw"
      withdraw_form_params
    end
  end

  def review_form_params
    params.require(:jobseekers_job_application_review_form).permit(:confirm_data_accurate, :confirm_data_usage, update_profile: [])
          .merge(completed_steps: job_application.completed_steps, all_steps: all_steps)
  end

  def withdraw_form_params
    (params[:jobseekers_job_application_withdraw_form] || params).permit(:withdraw_reason)
  end

  def vacancy
    @vacancy ||= if params[:job_id].present?
                   Vacancy.live.find(params[:job_id])
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
    current_jobseeker.job_applications.not_draft.any?
  end

  def quick_apply?
    previous_application? || profile.present?
  end

  def all_steps
    Jobseekers::JobApplications::JobApplicationHandler.new(job_application, step_process).all_steps
  end
end
# rubocop:enable Metrics/ClassLength
