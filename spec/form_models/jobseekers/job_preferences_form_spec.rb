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

  describe "validations on roles form" do
    let(:roles) { Jobseekers::JobPreferencesForm::RolesForm.new(roles: %w[a b c d e]) }

    it "has a custom error for too many roles" do
      expect(roles).not_to be_valid
      expect(roles.errors.messages).to eq({ roles: ["You can only select a maximum of 4 roles"] })
    end
  end

  describe "validations on key stages form" do
    let(:key_stages) { Jobseekers::JobPreferencesForm::KeyStagesForm.new(key_stages: %w[a b c d]) }

    it "has a custom error for too many roles" do
      expect(key_stages).not_to be_valid
      expect(key_stages.errors.messages).to eq({ key_stages: ["You can only select a maximum of 3 key stages"] })
    end
  end
end
