class MoveJobPreferencesToJobseekersProfile < ActiveRecord::Migration[7.0]
  class JobPreferences < ActiveRecord::Base
    belongs_to :jobseeker, required: false
    belongs_to :jobseeker_profile, required: false
  end

  class JobseekerProfile < ActiveRecord::Base
    belongs_to :jobseeker
    has_one :jobseeker_preferences
  end

  class Jobseeker < ActiveRecord::Base
    has_one :jobseeker_profile
    has_one :job_preferences
  end

  def change
    add_reference :job_preferences, :jobseeker_profile, type: :uuid, foreign_key: true

    reversible do |dir|
      dir.up do
        JobPreferences.includes(jobseeker: :jobseeker_profile).find_each do |jp|
          jp.update!(jobseeker_profile: jp.jobseeker.jobseeker_profile)
        end
      end

      dir.down do
        JobPreferences.reset_column_information

        JobPreferences.includes(jobseeker_profile: :jobseeker).find_each do |jp|
          jp.update!(jobseeker: jp.jobseeker_profile.jobseeker)
        end
      end
    end

    remove_reference :job_preferences, :jobseeker, type: :uuid, foreign_key: true
  end
end
