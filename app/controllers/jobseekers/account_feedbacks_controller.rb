class Jobseekers::AccountFeedbacksController < Jobseekers::ApplicationController
  def new
    @account_feedback = current_jobseeker.account_feedbacks.build(back_link: params[:back_link])
  end

  def create
    @account_feedback = current_jobseeker.account_feedbacks.build(account_feedback_params)

    if @account_feedback.save
      redirect_to @account_feedback.back_link, success: t(".success")
    else
      render :new
    end
  end

  private

  def account_feedback_params
    params.require(:account_feedback).permit(:rating, :suggestions, :back_link)
  end
end
