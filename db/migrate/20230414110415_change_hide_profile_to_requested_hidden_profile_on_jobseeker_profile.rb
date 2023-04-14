class ChangeHideProfileToRequestedHiddenProfileOnJobseekerProfile < ActiveRecord::Migration[7.0]
  def change
    rename_column :jobseeker_profiles, :hide_profile, :requested_hidden_profile
  end
end
