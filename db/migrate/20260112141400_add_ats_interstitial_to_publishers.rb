class AddAtsInterstitialToPublishers < ActiveRecord::Migration[7.1]
  def change
    add_column :publishers, :acknowledged_ats_and_religious_form_interstitial, :boolean, default: false, null: false
    safety_assured do
      remove_column :publishers, :acknowledged_candidate_profiles_interstitial, :boolean, default: false
    end
  end
end
