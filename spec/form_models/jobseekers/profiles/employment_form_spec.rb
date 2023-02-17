require "rails_helper"

RSpec.describe Jobseekers::Profile::EmploymentForm, type: :model do
  it { is_expected.to validate_presence_of(:organisation) }
  it { is_expected.to validate_presence_of(:job_title) }
  it { is_expected.to validate_presence_of(:started_on) }

  context "when #ended_on is present" do
    context "when #start_on is after #ended_on" do
      subject { described_class.new(started_on: Date.today, ended_on: Date.yesterday) }

      it "adds an error to the form" do
        subject.valid?

        expect(subject.errors.added?(:started_on, :before)).to be true
      end
    end

    context "when #start_on is after #ended_on" do
      subject { described_class.new(started_on: Date.today, ended_on: Date.yesterday) }

      it "does not add an error to the form" do
        subject.valid?

        expect(subject.errors.added?(:started_on, :before)).to be true
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
