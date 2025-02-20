# frozen_string_literal: true

require "rails_helper"

RSpec.describe Jobseekers::JobApplication::ReferencesForm do
  let(:reference_with_current_employer) { create(:reference, is_most_recent_employer: true) }
  let(:reference_without_current_employer) {  create(:reference, is_most_recent_employer: false) }

  subject { described_class.new(references: references, references_section_completed: true) }

  context "when at least one reference is from the most recent employer" do
    let(:references) { [reference_with_current_employer] }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "when no references are from the most recent employer" do
    let(:references) { [reference_without_current_employer] }

    it "is not valid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:references]).to include("At least one reference must be marked as the most recent employer.")
    end
  end

  context "when there are no references" do
    let(:references) { [] }

    it "is not valid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:references]).to include("At least one reference must be marked as the most recent employer.")
    end
  end
end
