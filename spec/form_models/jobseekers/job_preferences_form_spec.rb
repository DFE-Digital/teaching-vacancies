require "rails_helper"

RSpec.describe Jobseekers::JobPreferencesForm, type: :model do
  subject(:multistep) { described_class.new initial_attributes }
  let(:initial_attributes) { {} }

  describe "`roles` step" do
    subject(:step) { multistep.steps[:roles] }
    it { is_expected.to validate_presence_of :roles }
  end

  describe "`phases` step" do
    subject(:step) { multistep.steps[:phases] }
    it { is_expected.to validate_presence_of :phases }
  end

  describe "`key_stages` step" do
    subject(:step) { multistep.steps[:key_stages] }
    it { is_expected.to validate_presence_of :key_stages }

    describe "#options" do
      it "depend on the value of phases" do
        expect(step.options.keys).to eq %w[non_teaching]

        multistep.phases = %w[primary]
        expect(step.options.keys).to eq %w[early_years ks1 ks2 non_teaching]

        multistep.phases = %w[nursery secondary]
        expect(step.options.keys).to eq %w[early_years ks3 ks4 ks5 non_teaching]
      end
    end

    describe "invalidate?" do
      let(:initial_attributes) { { phases: %w[primary], key_stages: %w[early_years ks1] } }

      context "when new options are added in a result of change of phases" do
        it "invalidates the step" do
          multistep.phases = %w[primary secondary]
          expect(step.invalidate?).to be true
        end
      end

      context "when change of phases removes all selected key stages options" do
        it "invalidates the step and truncates the selected stages" do
          multistep.phases = %w[secondary]

          expect(step.invalidate?).to be true
          expect(step.key_stages).to eq []
        end
      end

      context "when change of phases remove some of the selected stages, but not all" do
        it "truncates the selected stages but does not invalidate the step" do
          multistep.phases = %w[nursery]
          expect(step.invalidate?).to be false
          expect(step.key_stages).to eq %w[early_years]
        end
      end
    end
  end

  describe "`subjects` step" do
    subject(:step) { multistep.steps[:subjects] }
    it { is_expected.not_to validate_presence_of :subjects }

    describe "#skip?" do
      context "when user selected any of ks3+ stages" do
        let(:initial_attributes) { { key_stages: %w[ks3] } }

        it "the subjects step is not skipped" do
          expect(step.skip?).to be false
        end
      end

      context "when user selected any of ks3+ stages" do
        let(:initial_attributes) { { key_stages: %w[ks1 ks2], subjects: %w[history art] } }

        it "the subjects step is skipped and subject list is cleared" do
          expect(step.skip?).to be true
          expect(step.subjects).to eq []
        end
      end
    end
  end

  describe "`working_patterns` step" do
    subject(:step) { multistep.steps[:working_patterns] }
    it { is_expected.to validate_presence_of :working_patterns }

    describe "#working_pattern_details_does_not_exceed_maximum_words" do
      context "when working_pattern_details is too long" do
        let(:initial_attributes) { { working_pattern_details: "word " * 51 } }

        it "adds an error" do
          step.valid?
          expect(step.errors[:working_pattern_details]).to include("is too long")
        end
      end

      context "when working_pattern_details is within the limit" do
        let(:initial_attributes) { { working_pattern_details: "word " * 49 } }

        it "does not add an error" do
          step.valid?
          expect(step.errors[:working_pattern_details]).to be_empty
        end
      end
    end
  end
end
