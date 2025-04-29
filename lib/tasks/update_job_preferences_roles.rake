namespace :job_preferences do
  desc "Replace 'other_teaching_support' with 'other_support' in job_preferences.roles"
  task update_roles: :environment do
    job_prefs = JobPreferences.where("'other_teaching_support' = ANY(roles)")
    updated_count = 0

    puts "#{job_prefs.count} JobPreferences to update"

    job_prefs.find_each do |pref|
      new_roles = pref.roles.map { |role|
        role == "other_teaching_support" ? "other_support" : role
      }.uniq

      pref.assign_attributes(roles: new_roles)
      pref.save!(touch: false)
      puts "Updated JobPreferences id: #{pref.id}"
      updated_count += 1
    end

    puts "#{updated_count} JobPreferences records updated."
  end
end
