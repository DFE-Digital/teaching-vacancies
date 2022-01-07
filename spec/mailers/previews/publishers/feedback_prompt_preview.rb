# Documentation: app/mailers/previewing_emails.md
class Publishers::FeedbackPromptPreview < ActionMailer::Preview
  def prompt_for_feedback
    unless Publisher.any? && Vacancy.count > 1
      raise "I don't want to mess up your development database with factory-created records, so this preview won't
            run unless there is >=1 publisher and >=2 vacancies in the database."
    end

    Publishers::ExpiredVacancyFeedbackPromptMailer.prompt_for_feedback(Publisher.first, [Vacancy.first, Vacancy.second, Vacancy.third, Vacancy.fourth, Vacancy.fifth])
  end
end
