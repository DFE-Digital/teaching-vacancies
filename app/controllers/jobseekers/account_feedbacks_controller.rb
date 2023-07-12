class Jobseekers::AccountFeedbacksController < Jobseekers::BaseController
  def new
    @account_feedback_form = Jobseekers::AccountFeedbackForm.new(origin_path: params[:origin])
  end

  def create
    @account_feedback_form = Jobseekers::AccountFeedbackForm.new(account_feedback_form_params)

    if @account_feedback_form.valid?
      Feedback.create(feedback_attributes)
      redirect_to @account_feedback_form.origin_path, success: t(".success")
    else
      render :new
    end
  end

  private

  def account_feedback_form_params
    params.require(:jobseekers_account_feedback_form)
          .permit(:comment, :email, :origin_path, :rating, :report_a_problem, :user_participation_response, :occupation)
  end

  def feedback_attributes
    account_feedback_form_params.except("report_a_problem").merge(jobseeker_id: current_jobseeker.id, feedback_type: "jobseeker_account")
  end
end
