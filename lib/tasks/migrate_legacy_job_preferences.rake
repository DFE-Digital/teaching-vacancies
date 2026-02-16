desc "Migrate legacy job preferences"
task migrate_legacy_job_preferences: :environment do
  JobPreferences.where.not(working_patterns: nil).find_each do |jp|
    if jp.working_patterns.include?("term_time")
      jp.assign_attributes(working_patterns: (jp.working_patterns - %w[term_time] + %w[full_time]).uniq)
    end
    if jp.working_patterns.include?("flexible")
      jp.assign_attributes(working_patterns: (jp.working_patterns - %w[flexible] + %w[part_time]).uniq)
    end
    jp.save!(validate: false, touch: false)
  end
end
