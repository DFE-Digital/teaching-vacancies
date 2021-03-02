# Preview all emails at http://localhost:3000/rails/mailers
class FeedbackPromptPreview < ActionMailer::Preview
  def prompt_for_feedback
    unless Publisher.any? && Vacancy.count > 1
      raise "I don't want to mess up your development database with factory-created records, so this preview won't
            run unless there is >=1 publisher and >=2 vacancies in the database."
    end

    FeedbackPromptMailer.prompt_for_feedback(Publisher.first, [Vacancy.first, Vacancy.second])
  end
end
