# lib/tasks/update_vacancy.rake

namespace :vacancy do
  desc "Update vacancies with visa_sponsorship_available == nil to be false"
  task update_visa_sponsorship: :environment do
    Vacancy.where(visa_sponsorship_available: nil).update_all(visa_sponsorship_available: false)
  end
end
