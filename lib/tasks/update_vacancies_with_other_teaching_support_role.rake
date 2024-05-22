namespace :vacancy do
  desc "Update job roles from 'other_teaching_support' (10) to 'other_support' (16)"
  task update_job_roles: :environment do
    vacancies = Vacancy.where("job_roles @> ARRAY[?]::integer[]", [10])
    updated_count = 0

    vacancies.find_each do |vacancy|
      new_roles = vacancy.job_roles.map { |role| role == "other_teaching_support" ? "other_support" : role }.uniq
      vacancy.update(job_roles: new_roles)
      updated_count += 1
    end

    puts "#{updated_count} vacancies updated."
  end
end
