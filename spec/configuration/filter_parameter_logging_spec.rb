require "rails_helper"

RSpec.describe "Filter parameter logging configuration" do
  let(:analytics_hidden_pii) { Rails.application.config_for(:analytics_hidden_pii) }
  let(:filter_params) { Rails.application.config.filter_parameters }

  specify "all anonymised analytics fields should be filtered from logs" do
    analytics_hidden_pii.each_value do |shared|
      shared.map(&:to_sym).each do |field|
        expect(filter_params).to include(field)
      end
    end
  end
end
