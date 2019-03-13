namespace :daily_emails do
  task :send_sample, [:email] => :environment do |_t, args|
    subscription = Subscription.find_or_create_by(email: args[:email], frequency: :daily)
    vacancies = Vacancy.all.count.zero? ? FactoryBot.create_list(:vacancy, 5) : Vacancy.all.sample(5)
    AlertMailer.daily_alert(subscription.id, vacancies.pluck(:id)).deliver_later
  end
end