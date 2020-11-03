namespace :feedback_prompt_email do
  task send: :environment do
    SendExpiredVacancyFeedbackEmailJob.perform_now
  end
end
