namespace :job_alerts do
  task :send_sample, [:email] => :environment do |_t, args|
    subscription = FactoryBot.create(:subscription, email: args[:email])
    subscription.save
    vacancies = Vacancy.all.count.zero? ? FactoryBot.create_list(:vacancy, 5) : Vacancy.all.sample(5)
    AlertMailer.alert(subscription.id, vacancies.pluck(:id)).deliver_now!
  end
end
