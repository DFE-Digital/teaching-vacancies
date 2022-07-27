class Publishers::ExpiredVacancyFeedbackPromptMailer < Publishers::BaseMailer
  def prompt_for_feedback(publisher, vacancies)
    @template = template
    @publisher = publisher
    @to = publisher.email

    @vacancies = vacancies

    view_mail(@template, to: @to, subject: "Teaching Vacancies needs your feedback on closed job listings")
  end
end
