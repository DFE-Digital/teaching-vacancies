namespace :vacancies do
  desc "Update middle school vacancies with primary secondary as appropriate"
  task remove_middle_school: :environment do
    mapper = Vacancies::Import::Sources::Fusion.new
    # middle phase has been removed, so it maps to nil
    Vacancy.active.find_each.select { |v| v.phases.include? nil }.each do |vacancy|
      extra_phases = mapper.map_middle_school_phase(vacancy.organisation.phase)
      vacancy.assign_attributes(phases: (vacancy.phases.compact + extra_phases).uniq)
      vacancy.save!(touch: false)
    end
  end
end
