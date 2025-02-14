class AddQtsAgeRangeAndSubject < ActiveRecord::Migration[7.2]
  def change
    add_column :job_applications, :qts_age_range_and_subject, :string
    add_column :jobseeker_profiles, :qts_age_range_and_subject, :string
  end
end
