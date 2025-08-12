require "rails_helper"

module Publishers
  module JobApplication
    RSpec.describe TagForm, type: :model do
      subject(:tag_form) { described_class.new(job_applications:, status:, origin:, validate_status:) }

      let(:job_applications) { create_list(:job_application, 2, :status_submitted) }
      let(:status) { "shortlisted" }
      let(:origin) { "submitted" }

      describe "validation" do
        context "when validate_status evaluates to truthy" do
          let(:validate_status) { "false" }

          it { is_expected.to validate_length_of(:job_applications) }
          it { is_expected.to validate_presence_of(:status) }
          it { is_expected.to validate_inclusion_of(:status).in_array(%w[submitted unsuccessful reviewed shortlisted interviewing offered declined unsuccessful_interview]) }
        end

        context "when validate_status evaluates to falsey" do
          let(:validate_status) { nil }

          it { is_expected.to validate_length_of(:job_applications) }
          it { is_expected.not_to validate_presence_of(:status) }
        end
      end

      describe ".attributes" do
        subject(:attributes) do
          described_class.new(job_applications:, status:, origin:, offered_at:, declined_at:, interview_feedback_received_at:).attributes
        end

        let(:offered_at) { 1.day.ago }
        let(:declined_at) { 2.days.ago }
        let(:interview_feedback_received_at) { 3.days.ago }

        context "when status offered" do
          let(:status) { "offered" }

          it { is_expected.to eq({ "status" => status, "offered_at" => offered_at }) }
        end

        context "when status declined" do
          let(:status) { "declined" }

          it { is_expected.to eq({ "status" => status, "declined_at" => declined_at }) }
        end

        context "when status unsuccessful_interview" do
          let(:status) { "unsuccessful_interview" }

          it { is_expected.to eq({ "status" => status, "interview_feedback_received_at" => interview_feedback_received_at }) }
        end

        context "when status any other" do
          let(:status) { "submitted" }

          it { is_expected.to eq({ "status" => status }) }
        end
      end
    end
  end
end
