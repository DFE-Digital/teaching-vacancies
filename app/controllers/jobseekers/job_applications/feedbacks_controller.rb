class Jobseekers::JobApplications::FeedbacksController < Jobseekers::JobApplicationsController
  include FeedbackEventConcerns

  def create
    @application_feedback_form = Jobseekers::JobApplication::FeedbackForm.new(feedback_form_params)

    if @application_feedback_form.valid?
      Feedback.create(feedback_attributes)
      trigger_feedback_provided_event
      redirect_to jobseekers_job_applications_path, success: t(".success")
    else
      render :submit
    end
  end

  private

  def feedback_form_params
    params.require(:jobseekers_job_application_feedback_form).permit(:rating, :comment)
  end

  def feedback_attributes
    feedback_form_params.merge(
      application_id: job_application.id,
      feedback_type: "application",
      jobseeker_id: current_jobseeker.id,
    )
  end
end
