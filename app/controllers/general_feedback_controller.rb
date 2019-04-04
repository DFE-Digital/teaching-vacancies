class GeneralFeedbackController < ApplicationController
  def new
    @feedback = GeneralFeedback.new
  end

  def create
    @feedback = GeneralFeedback.create(rating: general_feedback_params[:rating],
                                       comment: general_feedback_params[:comment])

    return render 'new' unless @feedback.save

    Auditor::Audit.new(@feedback, 'feedback.create', current_session_id).log

    redirect_to root_path, notice: I18n.t('messages.feedback.submitted')
  end

  private

  def general_feedback_params
    params.require(:general_feedback).permit(:rating, :comment)
  end
end
