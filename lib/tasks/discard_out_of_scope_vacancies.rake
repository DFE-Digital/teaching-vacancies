namespace :vacancies do
  desc "Trash published vacancies from out-of-scope schools"
  task discard_out_of_scope: :environment do
    out_of_scope_vacancies = PublishedVacancy.kept
                                             .joins(:organisations)
                                             .where(organisations: {
                                               detailed_school_type: Organisation::OUT_OF_SCOPE_DETAILED_SCHOOL_TYPES
                                             })
                                             .distinct

    out_of_scope_vacancies.find_each(&:trash!)
  end
end
