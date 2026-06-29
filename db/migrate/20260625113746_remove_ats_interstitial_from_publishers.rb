class RemoveAtsInterstitialFromPublishers < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :publishers, :acknowledged_ats_and_religious_form_interstitial, :boolean, default: false, null: false
    end
  end
end
