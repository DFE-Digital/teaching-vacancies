namespace :vacancies do
  desc "Remove old working patterns from vacancies"
  task remove_working_patterns: :environment do
    # these are the working_patterns that we want to remove
    old_patterns = [101, 102, 103, 104]
    # query to find vacancies where at least one of the old working patterns is included in the working_patterns
    vacancies = Vacancy.where("working_patterns && ARRAY[?]::integer[]", old_patterns)

    vacancies.each do |vacancy|
      # remove the old working patterns
      new_working_patterns = vacancy.working_patterns - ["term_time", "job_share", "flexible", nil]
      # add "part_time" to replace the old working pattern unless it is already there.
      new_working_patterns << "part_time" unless vacancy.working_patterns.include?("part_time")
      vacancy.update(working_patterns: new_working_patterns)
    end
  end
end
