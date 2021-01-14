class Jobseekers::SavedJobsController < Jobseekers::ApplicationController
  before_action :set_up_saved_job, only: %i[new destroy]

  def new
    @saved_job.save
    redirect_to job_path(@vacancy), success: t(".success_html", link: jobseekers_saved_jobs_path)
  end

  def destroy
    @saved_job.destroy
    if saved_job_params[:redirect_to_dashboard] == "true"
      redirect_to jobseekers_saved_jobs_path, success: t(".success")
    else
      redirect_to job_path(@vacancy)
    end
  end

  def index
    @sort = Jobseekers::SavedJobSort.new.update(column: params[:sort_column])
    @sort_form = SortForm.new(@sort.column)
    @saved_jobs = current_jobseeker.saved_jobs.includes(:vacancy).order("#{@sort.column} #{@sort.order}")
  end

  private

  def saved_job_params
    ParameterSanitiser.call(params).permit(:id, :redirect_to_dashboard)
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
