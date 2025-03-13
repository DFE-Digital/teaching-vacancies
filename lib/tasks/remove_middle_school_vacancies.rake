namespace :vacancies do
  desc "Update middle school vacancies with primary secondary as appropriate"
  task remove_middle_school: :environment do
    mapper = Vacancies::Import::Sources::Fusion.new
    # middle phase has been removed, so it maps to nil
    Vacancy.expired.invert_where.find_each.select { |v| v.phases.include? nil }.each do |vacancy|
      extra_phases = mapper.map_middle_school_phase(organisation.phase)
      vacancy.update!(phases: (vacancy.phases.compact + extra_phases).uniq, touch: false)
    end
  end
end
