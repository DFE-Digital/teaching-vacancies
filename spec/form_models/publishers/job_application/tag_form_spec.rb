require "rails_helper"

module Publishers
  module JobApplication
    RSpec.describe TagForm, type: :model do
      subject(:tag_form) { described_class.new(job_applications:, status:, origin:, validate_status:) }

      let(:job_applications) { create_list(:job_application, 2, :status_submitted) }
      let(:status) { "shortlisted" }
      let(:origin) { "submitted" }

      describe "validation" do
        context "when validate_status evalutes to truthy" do
          let(:validate_status) { "false" }

          it { is_expected.to validate_length_of(:job_applications) }
          it { is_expected.to validate_presence_of(:status) }
          it { is_expected.to validate_inclusion_of(:status).in_array(%w[submitted unsuccessful reviewed shortlisted interviewing]) }
        end

        context "when validate_status evaluates to falsy" do
          let(:validate_status) { nil }

          it { is_expected.to validate_length_of(:job_applications) }
        end
      end
    end
  end
end
