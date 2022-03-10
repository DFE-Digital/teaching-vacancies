class Jobseekers::JobApplications::FeedbacksController < Jobseekers::BaseController
  helper_method :vacancy

  def create
    @application_feedback_form = Jobseekers::JobApplication::FeedbackForm.new(feedback_form_params)

    if @application_feedback_form.valid?
      Feedback.create(feedback_attributes)
      redirect_to jobseekers_job_applications_path, success: t(".success")
    else
      render "jobseekers/job_applications/submit"
    end
  end

  private

  def feedback_form_params
    params.require(:jobseekers_job_application_feedback_form)
          .permit(:email, :rating, :comment, :user_participation_response)
          .each_value { |value| value.try(:strip!) unless value.frozen? }
  end

  def feedback_attributes
    feedback_form_params.merge(
      job_application_id: job_application.id,
      feedback_type: "application",
      jobseeker_id: current_jobseeker.id,
    )
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.find(params[:job_application_id])
  end

  def vacancy
    @vacancy ||= job_application.vacancy
  end
end
