namespace :feedback_prompt_email do
  desc "Send expired vacancy feedback email"
  task send: :environment do
    SendExpiredVacancyFeedbackEmailJob.perform_now
  end
end
