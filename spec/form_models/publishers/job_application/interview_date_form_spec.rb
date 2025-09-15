require "rails_helper"

module Publishers
  module JobApplication
    RSpec.describe InterviewDateForm, type: :model do
      subject(:form) { described_class.new(intervewing_at:, job_application_id:) }

      let(:job_application_id) { "job_application_id" }

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
