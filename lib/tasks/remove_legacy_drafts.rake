namespace :vacancies do
  desc "Remove legaqcy draft vacancies"
  task remove_legacy_drafts: :environment do
    Vacancy.draft.find_each.select { |v| v.legacy_draft? }.each do |v|
      v.destroy!
    end
  end
end
