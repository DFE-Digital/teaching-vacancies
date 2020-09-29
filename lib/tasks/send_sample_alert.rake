namespace :daily_emails do
  task :send_sample, [:email] => :environment do |_t, args|
    subscription = Subscription.find_or_create_by(email: args[:email], frequency: :daily)
    subscription.search_criteria = { subject: 'English' }.to_json if subscription.search_criteria.blank?
    subscription.save
    vacancies = Vacancy.all.count.zero? ? FactoryBot.create_list(:vacancy, 5) : Vacancy.all.sample(5)
    AlertMailer.alert(subscription.id, vacancies.pluck(:id)).deliver_now!
  end
end
