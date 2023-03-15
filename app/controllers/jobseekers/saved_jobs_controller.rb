class Jobseekers::SavedJobsController < Jobseekers::BaseController
  helper_method :saved_jobs, :sort

  def index
    redirect_to jobseekers_job_applications_path if session.delete(:after_sign_in) && current_jobseeker.job_applications.any?
  end

  # This action is not 'create' because we need to redirect here when an unauthenticated jobseeker attempts to save a job
  def new
    saved_job.save
    redirect_to job_path(vacancy), success: t(".success_html", link: jobseekers_saved_jobs_path)
  end

  def destroy
    saved_job.destroy
    if saved_job_params[:redirect_to_dashboard] == "true"
      redirect_to jobseekers_saved_jobs_path, success: t(".success")
    else
      redirect_to job_path(vacancy)
    end
  end

  private

  def candidate_profile_complete?
    profile = current_jobseeker.jobseeker_profile

    return unless profile

    personal_details = profile.personal_details
    job_preferences = profile.job_preferences

    section_completed(personal_details) && section_completed(job_preferences)
  end
  helper_method :candidate_profile_complete?

  def saved_job
    @saved_job ||= current_jobseeker.saved_jobs.find_or_initialize_by(vacancy_id: vacancy.id)
  end

  def saved_jobs
    @saved_jobs ||= current_jobseeker.saved_jobs.includes(:vacancy).order("#{sort.by} #{sort.order}")
  end

  def saved_job_params
    params.permit(:job_id, :redirect_to_dashboard)
  end

  def sort
    @sort ||= Jobseekers::SavedJobSort.new.update(sort_by: params[:sort_by])
  end

  def vacancy
    @vacancy ||= Vacancy.listed.find(saved_job_params[:job_id])
  end

  def section_completed(record)
    return if record.completed_steps.blank?

    step_phases = %w[completed skipped]
    record.completed_steps.values.all? { |step| step_phases.include?(step) }
  end
end
