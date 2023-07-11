class GeneralFeedbacksController < ApplicationController
  def new
    origin_path = URI.parse(request.referrer).path if request.referrer.present?
    @general_feedback_form = GeneralFeedbackForm.new(user_type: current_user&.class, origin_path:)
  end

  def create
    @general_feedback_form = GeneralFeedbackForm.new(general_feedback_form_params)
    @feedback = Feedback.new(feedback_attributes)

    if @general_feedback_form.invalid?
      render :new
    elsif recaptcha_is_invalid?
      redirect_to invalid_recaptcha_path(form_name: @general_feedback_form.class.name.underscore.humanize)
    else
      @feedback.recaptcha_score = recaptcha_reply["score"]
      @feedback.save
      redirect_to root_path, success: t(".success")
    end
  end

  private

  def general_feedback_form_params
    params.require(:general_feedback_form)
          .permit(:comment,
                  :email,
                  :report_a_problem,
                  :user_participation_response,
                  :visit_purpose,
                  :rating,
                  :visit_purpose_comment,
                  :occupation,
                  :user_type,
                  :origin_path)
  end

  def feedback_attributes
    general_feedback_form_params.except("report_a_problem", "user_type").merge(feedback_type: "general", jobseeker_id: current_jobseeker&.id, publisher_id: current_publisher&.id)
  end
end
