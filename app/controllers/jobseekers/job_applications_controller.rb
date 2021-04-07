class Jobseekers::JobApplicationsController < Jobseekers::BaseController
  include QualificationFormConcerns

  before_action :raise_unless_vacancy_enable_job_applications,
                :redirect_if_job_application_exists, only: %i[new create new_quick_apply quick_apply]

  helper_method :job_application, :qualification_form_param_key, :review_form, :vacancy, :withdraw_form

  def new
    request_event.trigger(:vacancy_apply_clicked, vacancy_id: vacancy.id)
    redirect_to new_quick_apply_jobseekers_job_job_application_path(vacancy.id) if
      current_jobseeker.job_applications.not_draft.any?
  end

  def create
    new_job_application = current_jobseeker.job_applications.create(vacancy: vacancy)
    redirect_to jobseekers_job_application_build_path(new_job_application, :personal_details)
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

    if params[:commit] == t("buttons.save_and_come_back")
      redirect_to jobseekers_job_applications_path, success: t("messages.jobseekers.job_applications.saved")
    elsif review_form.valid?
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
    raise ActionController::RoutingError, "Cannot withdraw non-submitted or non-shortlisted application" unless
      job_application.status.in?(%w[shortlisted submitted])
  end

  def withdraw
    raise ActionController::RoutingError, "Cannot withdraw non-submitted or non-shortlisted application" unless
      job_application.status.in?(%w[shortlisted submitted])

    if withdraw_form.valid?
      job_application.withdrawn!
      redirect_to jobseekers_job_applications_path, success: t(".success", job_title: vacancy.job_title)
    else
      render :confirm_withdraw
    end
  end

  private

  def job_application
    @job_application ||= current_jobseeker.job_applications.find(params[:job_application_id] || params[:id])
  end

  def redirect_if_job_application_exists
    job_application = current_jobseeker.job_applications.find_by(vacancy_id: vacancy.id)
    return unless job_application

    if job_application.submitted?
      redirect_to jobseekers_job_applications_path,
                  warning: t("messages.jobseekers.job_applications.already_exists.submitted",
                             job_title: vacancy.job_title)
    elsif job_application.draft?
      redirect_to jobseekers_job_applications_path,
                  warning: t("messages.jobseekers.job_applications.already_exists.draft_html",
                             job_title: vacancy.job_title, link: jobseekers_job_application_review_path(job_application))
    end
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
          .merge(completed_steps: job_application.completed_steps)
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
