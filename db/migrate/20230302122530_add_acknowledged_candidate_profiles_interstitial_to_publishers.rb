class AddAcknowledgedCandidateProfilesInterstitialToPublishers < ActiveRecord::Migration[7.0]
  def change
    add_column :publishers, :acknowledged_candidate_profiles_interstitial, :boolean, null: false, default: false
  end
end
