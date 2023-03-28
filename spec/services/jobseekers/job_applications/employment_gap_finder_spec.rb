require "rails_helper"

RSpec.describe Jobseekers::JobApplications::EmploymentGapFinder do
  subject(:finder) { described_class.new(job_application) }

  let(:job_application) { build(:job_application, employments:) }
  let(:employments) { nil }

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  describe "#significant_gaps(threshold: 3.months)" do
    subject(:gaps) { finder.significant_gaps }

    context "when there are no employments" do
      let(:employments) { [] }

      it { is_expected.to be_empty }
    end

    context "when there is one employment and it is current" do
      let(:employments) { [build(:employment, :current_role, started_on:)] }
      let(:started_on) { 6.months.ago.to_date }

      it { is_expected.to be_empty }
    end

    context "when there is one employment and it just ended" do
      let(:employments) { [build(:employment, started_on:, ended_on:)] }
      let(:started_on) { 6.months.ago.to_date }
      let(:ended_on) { Date.today }

      it { is_expected.to be_empty }
    end

    context "when there is one employment and it ended more than 3 months ago" do
      let(:employments) { [employment_with_gap] }
      let(:employment_with_gap) { build(:employment, started_on:, ended_on:) }
      let(:started_on) { 6.months.ago.to_date }
      let(:ended_on) { (3.months + 1.day).ago.to_date }

      it "identifies the gap as appearing after the employment" do
        expect(gaps).to eq(
          employment_with_gap => {
            started_on: ended_on + 1.day,
            ended_on: Time.zone.today,
          },
        )
      end
    end

    context "when there is a gap shorter than 3 months" do
      let(:employments) do
        [
          build(:employment,
                started_on: 1.year.ago.to_date,
                ended_on: 6.months.ago.to_date),
          build(:employment, :current_role,
                started_on: 4.months.ago.to_date),
        ]
      end

      it { is_expected.to be_empty }
    end

    context "where there is a gap shorter than 3 months but the subsequent employment also ends within that 3 months" do
      let(:employments) do
        [
          build(:employment,
                started_on: 1.year.ago.to_date,
                ended_on: 6.months.ago.to_date),
          build(:employment,
                started_on: 5.months.ago.to_date,
                ended_on: 4.month.ago.to_date),
          build(:employment, :current_role,
                started_on: 3.months.ago.to_date),
        ]
      end

      it { is_expected.to be_empty }
    end

    context "when there is a gap longer than 3 months between two employments" do
      let(:employments) do
        [
          build(:employment,
                started_on: 1.year.ago.to_date,
                ended_on: 6.months.ago.to_date),
          build(:employment, :current_role,
                started_on: 1.month.ago.to_date),
        ]
      end

      it "identifies the gap as appearing between the two employments" do
        expect(gaps).to eq(
          employments.first => {
            started_on: employments.first.ended_on + 1.day,
            ended_on: employments.second.started_on - 1.day,
          },
        )
      end

      context "when a longer threshold is specified" do
        subject(:gaps) { finder.significant_gaps(threshold: 6.months) }

        it { is_expected.to be_empty }
      end
    end

    context "when there is a gap longer than 3 months between two employments but a parallel employment reduces the gap" do
      let(:employments) do
        [
          build(:employment, # Would normally trigger a 5 month gap
                started_on: 1.year.ago.to_date,
                ended_on: 6.months.ago.to_date),
          build(:employment, # Parallel employment that reduces the gap to 1 month
                started_on: 8.months.ago.to_date,
                ended_on: 2.months.ago.to_date),
          build(:employment, :current_role,
                started_on: 1.month.ago.to_date),
        ]
      end

      it { is_expected.to be_empty }
    end

    context "when the current role is overlapping a significant gap" do
      let(:employments) do
        [
          build(:employment, :current_role,
                started_on: 12.years.ago.to_date),
          build(:employment,
                started_on: 10.years.ago.to_date,
                ended_on: 9.years.ago.to_date),
        ]
      end

      it { is_expected.to be_empty }
    end

    context "when the current role starts before the other employment ends" do
      let(:employments) do
        [
          build(:employment,
                started_on: 1.year.ago.to_date,
                ended_on: 4.months.ago.to_date),
          build(:employment, :current_role,
                started_on: 5.months.ago.to_date),
        ]
      end

      it { is_expected.to be_empty }
    end

    context "when there are multiple gaps in a sequence" do
      let(:employments) do
        [
          build(:employment,
                started_on: 2.years.ago.to_date,
                ended_on: 1.year.ago.to_date),
          build(:employment,
                started_on: 6.months.ago.to_date,
                ended_on: 4.months.ago.to_date),
        ]
      end

      it "identifies all gaps" do
        expect(gaps).to eq(
          employments.first => {
            started_on: employments.first.ended_on + 1.day,
            ended_on: employments.second.started_on - 1.day,
          },
          employments.second => {
            started_on: employments.second.ended_on + 1.day,
            ended_on: Time.zone.today,
          },
        )
      end
    end
  end
end
