require "rails_helper"

RSpec.describe Jobseekers::JobPreferencesForm, type: :model do
  describe "#delegated_attributes" do
    it "has the steps inverted" do
      expect(described_class.delegated_attributes).to eq({ roles: :roles,
                                                           phases: :phases,
                                                           key_stages: :key_stages,
                                                           subjects: :subjects,
                                                           working_patterns: :working_patterns,
                                                           working_pattern_details: :working_patterns,
                                                           locations: :locations })
    end
  end
end
