namespace :vacancy do
  desc "Update job roles from legacy value 10 to new value 16"
  task update_job_roles: :environment do
    vacancies = Vacancy.where("job_roles @> ARRAY[?]::integer[]", [10])
    puts "#{vacancies.count} vacancies with job roles including other_teaching_support"
    updated_count = 0

    vacancies.find_each do |vacancy|
      raw_roles = vacancy[:job_roles] || []
      next unless raw_roles.include?(10)

      new_roles = raw_roles.map { |role| role == 10 ? 16 : role }.uniq
      vacancy.update_column(:job_roles, new_roles)
      puts "Updated vacancy id #{vacancy.id}"
      updated_count += 1
    end

    puts "#{updated_count} vacancies updated."
  end
end
