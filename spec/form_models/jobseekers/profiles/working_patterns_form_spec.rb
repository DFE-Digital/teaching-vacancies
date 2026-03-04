# frozen_string_literal: true

require "rails_helper"

module Jobseekers
  module Profiles
    RSpec.describe JobPreferencesForm::WorkingPatternsForm do
      let(:form) { described_class.new(initial_attributes.merge(working_patterns: "full_time")) }

      context "when working_pattern_details is too long" do
        let(:initial_attributes) { { working_pattern_details: "word " * 51 } }

        it "adds an error" do
          expect(form).not_to be_valid
          expect(form.errors.full_messages).to eq(["Working pattern details must be 50 words or less"])
        end
      end

      context "when working_pattern_details is within the limit" do
        let(:initial_attributes) { { working_pattern_details: "word " * 49 } }

        it "does not add an error" do
          expect(form).to be_valid
        end
      end
    end
  end
end
