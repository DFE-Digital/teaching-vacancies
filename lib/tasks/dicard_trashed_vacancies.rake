namespace :vacancies do
  desc "Discard trashed vacancies"
  task discard_trashed: :environment do
    Vacancy.trashed.or(Vacancy.removed_from_external_system).find_each do |v|
      # when the 'middle school' phase was removed, some deleted vacancies didn't get updated
      # so they have phases with 'nil' in their arrays - this tidies them up so that they can be handled.
      v.assign_attributes(status: :published, discarded_at: v.updated_at, phases: v.phases.compact)
      v.save!(touch: false, validate: false)
    end
  end
end
