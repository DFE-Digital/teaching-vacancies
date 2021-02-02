class Jobseekers::AccountFeedbacksController < Jobseekers::ApplicationController
  def new
    @account_feedback_form = Jobseekers::AccountFeedbackForm.new(origin: params[:origin])
  end

  def create
    @account_feedback_form = Jobseekers::AccountFeedbackForm.new(feedback_params)

    if @account_feedback_form.valid?
      Feedback.create(feedback_params.except(:origin))
      trigger_feedback_provided_event
      redirect_to @account_feedback_form.origin, success: t(".success")
    else
      render :new
    end
  end

  private

  def feedback_params
    params.require(:jobseekers_account_feedback_form).permit(:rating, :comment, :origin)
          .merge(jobseeker_id: current_jobseeker.id, feedback_type: "jobseeker_account")
  end
end
