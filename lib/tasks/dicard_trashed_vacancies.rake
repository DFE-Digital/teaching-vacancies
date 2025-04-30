namespace :vacancies do
  desc "Discard trashed vacancies"
  task discard_trashed: :environment do
    Vacancy.trashed.or(Vacancy.removed_from_external_system).update_all(discarded_at: Time.current)
  end
end
