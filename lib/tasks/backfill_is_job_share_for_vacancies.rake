namespace :vacancies do
  desc "Update working_patterns to replace 'job_share' with 'part_time' and set is_job_share to true"
  task update_job_share: :environment do
    vacancies_to_update = Vacancy.where("101 = ANY(working_patterns)")

    vacancies_to_update.find_each do |vacancy|
      if vacancy.working_patterns.include?("job_share")
        updated_patterns = vacancy.working_patterns.map { |pattern| pattern == "job_share" ? Vacancy.working_patterns["part_time"] : Vacancy.working_patterns[pattern] }

        vacancy.update_columns(working_patterns: updated_patterns.uniq, is_job_share: true)

        puts "Updated vacancy with ID: #{vacancy.id}"
      end
    end
  end
end
