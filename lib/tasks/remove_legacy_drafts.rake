namespace :vacancies do
  desc "Remove legaqcy draft vacancies"
  task remove_legacy_drafts: :environment do
    Vacancy.draft
           .find_each
           .select(&:legacy_draft?)
           .each(&:destroy!)
  end
end
