require "rails_helper"

RSpec.describe "Landing page configuration" do
  it "each configured landing page has a corresponding complete set of translations" do
    keys = %w[banner_title]
    Rails.application.config.campaign_pages.each_key do |cp|
      keys.each do |key|
        i18n_key = "campaign_pages.#{cp}.#{key}"
        expect(I18n.t(i18n_key, default: nil)).not_to be_nil, "Expected a translation for #{i18n_key} but found none"
      end
    end
  end
end
