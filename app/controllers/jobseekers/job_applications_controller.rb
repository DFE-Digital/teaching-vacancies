class Jobseekers::JobApplicationsController < Jobseekers::JobApplications::BaseController
  include QualificationFormConcerns

  before_action :raise_unless_vacancy_enable_job_applications,
                :redirect_if_job_application_exists, only: %i[new create new_quick_apply quick_apply]
  before_action :redirect_unless_draft_job_application, only: %i[review]

  helper_method :employments, :job_application, :qualification_form_param_key, :review_form, :vacancy, :withdraw_form

  def new
    request_event.trigger(:vacancy_apply_clicked, vacancy_id: StringAnonymiser.new(vacancy.id))
    redirect_to new_quick_apply_jobseekers_job_job_application_path(vacancy.id) if
      current_jobseeker.job_applications.not_draft.any?
  end

  def create
    new_job_application = current_jobseeker.job_applications.create(vacancy: vacancy)
    redirect_to jobseekers_job_application_build_path(new_job_application, :personal_details)
  end

  def review
    session[:back_to_review] = (session[:back_to_review] || []).push(job_application.id).uniq
  end

  def new_quick_apply
    raise ActionController::RoutingError, "Cannot quick apply if there are no non-draft applications" unless
      current_jobseeker.job_applications.not_draft.any?
  end

  def quick_apply
    raise ActionController::RoutingError, "Cannot quick apply if there are no non-draft applications" unless
      current_jobseeker.job_applications.not_draft.any?

    new_job_application = Jobseekers::JobApplications::QuickApply.new(current_jobseeker, vacancy).job_application
    redirect_to jobseekers_job_application_review_path(new_job_application)
  end

  def submit
    raise ActionController::RoutingError, "Cannot submit application for non-listed job" unless vacancy.listed?
    raise ActionController::RoutingError, "Cannot submit non-draft application" unless job_application.draft?

    if review_form.valid? && all_steps_valid?
      job_application.submit!
      @application_feedback_form = Jobseekers::JobApplication::FeedbackForm.new
    else
      render :review
    end
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

  def all_steps_valid?
    # Check that all steps are valid, in case we have changed the validations since the step was completed.
    # NB: Only validates top-level step forms. Does not validate individual qualifications, employments, or references.
    step_process.steps.excluding(:review).all? { |step| step_valid?(step) }
  end

  def step_valid?(step)
    step_form = "jobseekers/job_application/#{step}_form".camelize.constantize
    form = step_form.new(job_application.slice(step_form.fields))

    form.valid?.tap do
      job_application.errors.merge!(form.errors)
    end
  end

  def employments
    @employments ||= job_application.employments.order(:started_on)
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.find(params[:job_application_id] || params[:id])
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
    raise ActionController::RoutingError, "Cannot apply for this vacancy" unless vacancy.enable_job_applications?
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
    params.require(:jobseekers_job_application_review_form).permit(:confirm_data_accurate, :confirm_data_usage)
          .merge(completed_steps: job_application.completed_steps, all_steps: step_process.steps.excluding(:review).map(&:to_s))
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
end
