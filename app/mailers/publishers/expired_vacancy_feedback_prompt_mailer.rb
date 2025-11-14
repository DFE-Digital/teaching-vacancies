class Publishers::ExpiredVacancyFeedbackPromptMailer < Publishers::BaseMailer
  def prompt_for_feedback(publisher, vacancy)
    @publisher = publisher
    @to = publisher.email

    @vacancy = vacancy

    send_email(to: @to, subject: "Did you fill your vacancy?")
  end
end
