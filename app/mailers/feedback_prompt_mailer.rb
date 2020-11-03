class FeedbackPromptMailer < ApplicationMailer
  def prompt_for_feedback(email, vacancies)
    @vacancies = vacancies

    view_mail(
      NOTIFY_PROMPT_FEEDBACK_FOR_EXPIRED_VACANCIES,
      to: [email],
      subject: "Teaching Vacancies needs your feedback on expired job listings",
    )
  end
end
