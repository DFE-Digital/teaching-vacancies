# lib/tasks/update_vacancy.rake

namespace :vacancy do
  desc "Update vacancies with visa_sponsorship_available == nil to be false"
  task update_visa_sponsorship: :environment do
    puts "Starting to update vacancies..."
    
    updated_count = Vacancy.where(visa_sponsorship_available: nil).update_all(visa_sponsorship_available: false)
    
    puts "Updated #{updated_count} vacancies."
  end
end
