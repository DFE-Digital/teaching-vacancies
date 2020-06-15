class GeneralFeedbackController < ApplicationController
  def new
    @feedback = GeneralFeedback.new
  end

  def create
    @feedback = GeneralFeedback.new(general_feedback_params)
    return render 'new' unless @feedback.valid?
    recaptcha_valid = verify_recaptcha(model: @feedback, action: 'feedback')

    # v3_recaptcha does not interact with the user in any way. All it does is give them a score based on a number of
    # heurisitics. For now, all we will do is attach the score to the submitted feedback. Once we have a representative
    # data sample, we can decide how we will act on it.
    #
    # https://developers.google.com/recaptcha/docs/v3
    @feedback.recaptcha_score = recaptcha_reply['score'] if recaptcha_valid && recaptcha_reply
    @feedback.save

    redirect_to root_path, success: I18n.t('messages.feedback.submitted')
  end

  private

  def general_feedback_params
    params.require(:general_feedback)
      .permit(:visit_purpose, :visit_purpose_comment, :comment, :user_participation_response, :email)
  end
end
