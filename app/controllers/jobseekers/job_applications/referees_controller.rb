class Jobseekers::JobApplications::RefereesController < Jobseekers::BaseController
  helper_method :back_path, :job_application, :referee

  def new
    @form = Jobseekers::JobApplication::Details::RefereeForm.new
  end

  def edit
    @form = Jobseekers::JobApplication::Details::RefereeForm.new(referee.slice(:name, :job_title, :organisation, :relationship, :email, :phone_number, :is_most_recent_employer))
  end

  def create
    @form = Jobseekers::JobApplication::Details::RefereeForm.new(referee_params)
    if @form.valid?
      job_application.referees.create!(referee_params)
      redirect_to back_path
    else
      render :new
    end
  end

  def update
    @form = Jobseekers::JobApplication::Details::RefereeForm.new(referee_params)
    if @form.valid?
      referee.update!(referee_params)
      redirect_to back_path
    else
      render :edit
    end
  end

  def destroy
    referee.destroy!
    redirect_to back_path, success: t(".success")
  end

  private

  def back_path
    @back_path ||= jobseekers_job_application_build_path(job_application, :referees)
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end

  def referee
    job_application.referees.find(params[:id])
  end

  def referee_params
    params.require(:jobseekers_job_application_details_referee_form)
          .permit(:name, :job_title, :organisation, :relationship, :email, :phone_number, :is_most_recent_employer)
  end
end
