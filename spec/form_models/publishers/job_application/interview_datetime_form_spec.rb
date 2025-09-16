require "rails_helper"

module Publishers
  module JobApplication
    RSpec.describe InterviewDatetimeForm, type: :model do
      subject(:form) { described_class.new(interview_date:, interview_time:, job_application:) }

      let(:job_application) { build_stubbed(:job_application, :status_interviewing) }
      let(:interview_date) { Date.new(2025, 9, 1) }
      let(:interview_time) { Time.zone.parse("10:45") }

      describe "validation" do
        context "when validate_status evaluates to truthy" do

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
    end
  end
end
