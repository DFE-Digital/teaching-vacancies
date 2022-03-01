require "rails_helper"

RSpec.describe "Landing page configuration" do
  specify "each configured landing page follows the expected slug format" do
    Rails.application.config.landing_pages.each_key do |lp|
      expect(lp).to match(/^[a-z0-9-]+$/), "expected '#{lp}' to only contain lowercase letters, numbers, and dashes"
    end
  end

  specify "each configured landing page has a corresponding complete set of translations" do
    Rails.application.config.landing_pages.each_key do |lp|
      %w[heading name meta_description title].each do |key|
        i18n_key = "landing_pages.#{lp}.#{key}"
        expect(I18n.t(i18n_key, default: nil)).not_to be_nil, "Expected a translation for #{i18n_key} but found none"
      end
    end
  end
end
