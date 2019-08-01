class GeneralFeedbackController < ApplicationController
  def new
    @feedback = GeneralFeedback.new
  end

  def create
    @feedback = GeneralFeedback.create(general_feedback_params)

    return render 'new' unless @feedback.save

    Auditor::Audit.new(@feedback, 'feedback.create', current_session_id).log

    redirect_to root_path, notice: I18n.t('messages.feedback.submitted')
  end

  private

  def general_feedback_params
    params.require(:general_feedback)
          .permit(:visit_purpose, :visit_purpose_comment, :comment, :user_participation_response, :email)
  end
end
