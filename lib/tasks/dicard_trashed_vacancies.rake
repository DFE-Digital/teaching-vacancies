namespace :vacancies do
  desc "Discard trashed vacancies"
  task discard_trashed: :environment do
    Vacancy.trashed.or(Vacancy.removed_from_external_system).find_each do |v|
      v.assign_attributes(status: :published, discarded_at: v.updated_at)
      v.save!(touch: false, validate: false)
    end
  end
end
