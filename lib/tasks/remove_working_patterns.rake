namespace :vacancies do
  desc "Remove old working patterns from vacancies"
  task remove_working_patterns: :environment do
    old_patterns = [Vacancy.working_patterns[:flexible], Vacancy.working_patterns[:job_share], Vacancy.working_patterns[:term_time]]
    vacancies = Vacancy.where("working_patterns && ARRAY[?]::integer[]", old_patterns)

    vacancies.each do |vacancy|
      new_working_patterns = vacancy.working_patterns - %w[term_time job_share flexible]
      new_working_patterns += ["part_time"] unless vacancy.working_patterns.include?("part_time")
      vacancy.update(working_patterns: new_working_patterns)
    end
  end
end
