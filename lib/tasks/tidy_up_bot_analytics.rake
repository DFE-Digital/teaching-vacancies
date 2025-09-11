namespace :vacancies do
  desc "Convert self-references from analytics into directs"
  task tidy_analytics: :environment do
    VacancyAnalytics.find_each do |va|
      va.tidy_stats
      va.save!
    end
  end
end
