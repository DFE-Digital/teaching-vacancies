require "rails_helper"

RSpec.describe Jobseekers::Profile::EmploymentForm, type: :model do
  it { is_expected.to validate_presence_of(:organisation) }
  it { is_expected.to validate_presence_of(:job_title) }
  it { is_expected.to validate_presence_of(:started_on) }

  context "when #ended_on is present" do
    context "when it is not the current role" do
      context "when #start_on is after #ended_on" do
        subject { described_class.new(started_on: Date.yesterday, ended_on: Date.yesterday - 1.day, current_role: "no") }

        it "adds an error to the form" do
          subject.valid?
          expect(subject.errors.added?(:ended_on, :on_or_after)).to be true
        end
      end

      context "when #start_on is before #ended_on" do
        subject { described_class.new(started_on: Date.yesterday, ended_on: Date.today, current_role: "no") }

        it "does not add an error to the form" do
          subject.valid?
          expect(subject.errors.added?(:ended_on, :on_or_after)).to be false
        end
      end

      context "when #ended_on is on the same day as #started_on" do
        subject { described_class.new(started_on: Date.yesterday, ended_on: Date.yesterday, current_role: "no") }

        it "does not add an error to the form" do
          subject.valid?
          expect(subject.errors.added?(:ended_on, :on_or_after)).to be false
        end
      end
    end
  end

  context "when #current_role is 'yes'" do
    it { is_expected.to validate_inclusion_of(:current_role).in_array(%w[yes no]) }
  end

  context "when #current_role is 'no'" do
    subject { described_class.new(current_role: "no") }

    it { is_expected.to validate_presence_of(:ended_on) }
  end
end
