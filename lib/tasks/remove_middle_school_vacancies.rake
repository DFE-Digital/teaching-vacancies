namespace :vacancies do
  desc "Update middle school vacancies with primary secondary as appropriate"
  task remove_middle_school: :environment do
    Vacancy.live.find_each do |vacancy|
      if vacancy.phases.include? "middle"
        extra_phases = case vacancy.organisation.phase
                       when "middle_deemed_primary"
                         ["primary"]
                       when "middle_deemed_secondary"
                         ["secondary"]
                       else
                         ["primary", "secondary"]
        end
        vacancy.phases.update!(phases: (vacancy.phases - ["middle"] + extra_phases).uniq)
      end
    end
  end
end
