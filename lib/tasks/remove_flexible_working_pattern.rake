# One-off task. Remove after running.
namespace :job_preferences do
  desc "Remove 'flexible' from job_preferences working_patterns"
  task remove_flexible_working_pattern: :environment do
    affected_count = 0

    JobPreferences.where("working_patterns @> ARRAY['flexible']::varchar[]").find_each do |job_preference|
      original_patterns = job_preference.working_patterns
      updated_patterns = original_patterns - %w[flexible]

      result = JobPreferences.where(id: job_preference.id)
                             .update_all(working_patterns: updated_patterns)

      if result == 1
        affected_count += 1
        puts "Updated JobPreference ID: #{job_preference.id}, removed 'flexible' from working patterns"
      else
        puts "Failed to update JobPreference ID: #{job_preference.id}"
      end
    end

    puts "Task completed: updated #{affected_count} job_preferences records"
  end
end
