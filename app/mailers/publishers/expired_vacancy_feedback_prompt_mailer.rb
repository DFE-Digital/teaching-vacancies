class Publishers::ExpiredVacancyFeedbackPromptMailer < Publishers::BaseMailer
  def prompt_for_feedback(publisher, vacancy)
    @template = template
    @publisher = publisher
    @to = publisher.email

    @vacancy = vacancy

    view_mail(@template, to: @to, subject: "Teaching Vacancies needs your feedback on closed job listings")
  end
end
