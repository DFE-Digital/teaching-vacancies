class Jobseekers::JobApplicationsController < Jobseekers::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns

  before_action :raise_unless_vacancy_enable_job_applications,
                :redirect_if_job_application_exists, only: %i[new create new_quick_apply quick_apply]
  before_action :redirect_unless_draft_job_application, only: %i[review]

  helper_method :employments, :job_application, :qualification_form_param_key, :review_form, :vacancy, :withdraw_form

  def new
    send_dfe_analytics_event

    return unless quick_apply?

    redirect_to about_your_application_jobseekers_job_job_application_path(vacancy.id)
  end

  def create
    new_job_application = current_jobseeker.job_applications.create(vacancy:)
    redirect_to jobseekers_job_application_build_path(new_job_application, :personal_details)
  end

  def review
    session[:back_to_review] = (session[:back_to_review] || []).push(job_application.id).uniq
  end

  # rubocop:disable Style/GuardClause
  def about_your_application
    if profile.nil? || profile&.personal_details&.right_to_work_in_uk? || vacancy.visa_sponsorship_available?
      redirect_to new_quick_apply_jobseekers_job_job_application_path(vacancy.id)
    end
  end
  # rubocop:enable Style/GuardClause

  def new_quick_apply
    raise ActionController::RoutingError, "Cannot quick apply if there's no profile or non-draft applications" unless quick_apply?
  end

  def quick_apply
    raise ActionController::RoutingError, "Cannot quick apply if there's no profile or non-draft applications" unless quick_apply?

    new_job_application = if profile
                            current_jobseeker.job_applications.build(vacancy:)
                          else
                            Jobseekers::JobApplications::QuickApply.new(current_jobseeker, vacancy).job_application
                          end

    prefill_application(new_job_application)
    new_job_application.save!

    redirect_to jobseekers_job_application_review_path(new_job_application)
  end

  def submit
    raise ActionController::RoutingError, "Cannot submit application for non-listed job" unless vacancy.listed?
    raise ActionController::RoutingError, "Cannot submit non-draft application" unless job_application.draft?

    if review_form.valid? && all_steps_valid?
      update_jobseeker_profile!(job_application, review_form)
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

  def update_jobseeker_profile!(job_application, form)
    profile = job_application.jobseeker.jobseeker_profile
    return unless profile.present?

    profile.replace_qualifications!(job_application.qualifications.map(&:duplicate)) if form.update_profile_qualifications?
    profile.replace_employments!(job_application.employments.map(&:duplicate)) if form.update_profile_work_history?
  end

  def all_steps_valid?
    # Check that all steps are valid, in case we have changed the validations since the step was completed.
    # NB: Only validates top-level step forms. Does not validate individual qualifications, employments, or references.
    step_process.steps.excluding(:review).all? { |step| step_valid?(step) }
  end

  def step_valid?(step)
    step_form = "jobseekers/job_application/#{step}_form".camelize.constantize
    form = step_form.new(job_application.slice(step_form.storable_fields))

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
    params.require(:jobseekers_job_application_review_form).permit(:confirm_data_accurate, :confirm_data_usage, update_profile: [])
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

  def send_dfe_analytics_event
    fail_safe do
      event = DfE::Analytics::Event.new
        .with_type(:vacancy_apply_clicked)
        .with_request_details(request)
        .with_response_details(response)
        .with_user(current_jobseeker)
        .with_data(vacancy_id: vacancy.id)

      DfE::Analytics::SendEvents.do([event])
    end
  end

  def prefill_application(application)
    return unless profile.present?

    application.assign_attributes(
      employments: profile.employments.map(&:duplicate),
      first_name: profile.personal_details&.first_name,
      last_name: profile.personal_details&.last_name,
      phone_number: profile.personal_details&.phone_number,
      qualifications: profile.qualifications.map(&:duplicate),
      training_and_cpds: profile.training_and_cpds.map(&:duplicate),
      qualified_teacher_status_year: profile.qualified_teacher_status_year || "",
      qualified_teacher_status: profile.qualified_teacher_status || "",
      right_to_work_in_uk: profile_right_to_work,
    )

    mark_step_completion(application)
  end

  def profile_right_to_work
    return "" if profile.personal_details&.right_to_work_in_uk.nil?

    profile.personal_details.right_to_work_in_uk? ? "yes" : "no"
  end

  def mark_step_completion(application)
    if application.first_name.present? || application.last_name.present? || application.phone_number.present? || application.right_to_work_in_uk.present?
      application.in_progress_steps += [:personal_details]
    end

    if application.employments.any?
      application.in_progress_steps += [:employment_history]
    end

    if application.qualified_teacher_status.present?
      application.in_progress_steps += [:professional_status]
    end

    if application.training_and_cpds.any?
      application.in_progress_steps += [:training_and_cpds]
    end

    return unless application.qualifications.present?

    application.in_progress_steps += [:qualifications]
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
end
