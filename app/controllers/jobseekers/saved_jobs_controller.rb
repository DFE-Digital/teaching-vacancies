class Jobseekers::SavedJobsController < Jobseekers::ApplicationController
  before_action :set_up_saved_job, only: %i[new destroy]

  def new
    @saved_job.save
    redirect_to job_path(@vacancy), success: I18n.t("messages.jobseekers.saved_jobs.new_html", link: jobseekers_saved_jobs_path)
  end

  def destroy
    @saved_job.destroy
    redirect_to job_path(@vacancy)
  end

  def index; end

private

  def saved_job_params
    ParameterSanitiser.call(params).permit(:id)
  end

  def set_up_saved_job
    begin
      @vacancy = Vacancy.listed.friendly.find(saved_job_params[:id])
    rescue ActiveRecord::RecordNotFound
      raise unless Vacancy.trashed.friendly.exists?(saved_job_params[:id])

      return render "/errors/trashed_vacancy_found", status: :not_found
    end
    @saved_job = SavedJob.find_or_initialize_by(jobseeker_id: current_jobseeker.id, vacancy_id: @vacancy.id)
  end
end
