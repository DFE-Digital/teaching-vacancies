# frozen_string_literal: true

require "rails_helper"

RSpec.describe Jobseekers::JobApplication::RefereesForm, type: :model do
  let(:form) { described_class.new(referees: referees, referees_section_completed: true, notify_before_contact_referers: true) }

  let(:reference_with_current_employer) { create(:referee, is_most_recent_employer: true) }
  let(:reference_without_current_employer) { create(:referee, is_most_recent_employer: false) }

  before { allow(Shoulda::Matchers).to receive(:warn) }

  it { is_expected.to validate_inclusion_of(:notify_before_contact_referers).in_array([true, false]) }

  context "when at least one reference is from the most recent employer" do
    let(:referees) { [reference_with_current_employer] }

    it "is valid" do
      expect(form).to be_valid
    end
  end

  context "when no references are from the most recent employer" do
    let(:referees) { [reference_without_current_employer] }

    it "is not valid" do
      expect(form).not_to be_valid
      expect(form.errors[:referees]).to include("At least one reference must be marked as the most recent employer.")
    end
  end

  context "when there are no references" do
    let(:referees) { [] }

    it "is not valid" do
      expect(form).not_to be_valid
      expect(form.errors[:referees]).to include("At least one reference must be marked as the most recent employer.")
    end
  end
end
