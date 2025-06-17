require "rails_helper"

module Publishers
  module JobApplication
    RSpec.describe OfferDeclineDateForm, type: :model do
      it { is_expected.to validate_length_of(:job_applications) }

      describe ".job_application_ids" do
        subject { described_class.new(job_applications:).job_application_ids }

        let(:job_application) { create(:job_application) }

        context "with a selection" do
          let(:job_applications) { ::JobApplication.where(id: job_application.id) }

          it { is_expected.to eq([job_application.id]) }
        end

        context "with no selection" do
          let(:job_applications) { ::JobApplication.where(id: "no-id") }

          it { is_expected.to eq([]) }
        end
      end

      describe "#.fields" do
        subject { described_class.fields }

        it { is_expected.to eq([:origin, :status, { job_applications: [] }]) }
      end

      describe ".attributes" do
        subject { described_class.new(status:, offered_at:, declined_at:).attributes }

        context "when status offered" do
          let(:status) { "offered" }
          let(:offered_at) { Date.new(2025, 2, 1) }
          let(:declined_at) { nil }

          it { is_expected.to match({ offered_at:, status: }.stringify_keys) }
        end

        context "when status declined" do
          let(:status) { "declined" }
          let(:offered_at) { nil }
          let(:declined_at) { Date.new(2025, 2, 1) }

          it { is_expected.to match({ declined_at:, status: }.stringify_keys) }
        end
      end
    end
  end
end
