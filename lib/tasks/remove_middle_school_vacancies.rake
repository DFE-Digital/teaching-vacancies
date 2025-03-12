namespace :vacancies do
  desc "Update middle school vacancies with primary secondary as appropriate"
  task remove_middle_school: :environment do
    Vacancy.expired.invert_where.find_each do |vacancy|
      # middle phase has been removed, so it maps to nil
      if vacancy.phases.include? nil
        extra_phases = organisation.map_middle_school_phase
        vacancy.update!(phases: (vacancy.phases.compact + extra_phases).uniq, touch: false)
      end
    end
  end
end
