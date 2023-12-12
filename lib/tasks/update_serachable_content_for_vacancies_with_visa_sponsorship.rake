namespace :vacancy do
  desc "Update searchable content for vacancies with visa sponsorship"
  task update_searchable_content: :environment do
    Vacancy.where(visa_sponsorship_available: true).find_each do |vacancy|
      vacancy.update!(searchable_content: vacancy.generate_searchable_content)
    end
  end
end
