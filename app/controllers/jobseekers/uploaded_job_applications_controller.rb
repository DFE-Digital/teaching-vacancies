class Jobseekers::UploadedJobApplicationsController < Jobseekers::JobApplications::BaseController

  helper_method :review_form, :vacancy

  before_action :set_job_application, only: %i[apply]

  def create
    new_job_application = current_jobseeker.uploaded_job_applications.create(vacancy:)
    redirect_to apply_jobseekers_uploaded_job_application_path(new_job_application)
  end

  def apply
    binding.pry
    #  apply_jobseekers_uploaded_job_application GET    /jobseekers/uploaded_job_applications/:id/apply(.:format)                                                    jobseekers/uploaded_job_applications#apply
    # jobseekers_uploaded_job_applications POST   /jobseekers/uploaded_job_applications(.:format)                                                              jobseekers/uploaded_job_applications#create
  end

  private

  def vacancy
    @vacancy ||= if params[:job_id].present?
                   Vacancy.live.find(params[:job_id])
                 else
                   job_application.vacancy
                 end
  end

  def review_form
    @review_form ||= Jobseekers::JobApplication::ReviewForm.new(form_attributes)
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
end