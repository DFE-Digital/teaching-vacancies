require "rails_helper"

module Publishers
  module JobApplication
    RSpec.describe TagForm, type: :model do
      subject(:tag_form) { described_class.new(job_applications:, status:, origin:, validate_all_attributes:) }

      let(:job_applications) { create_list(:job_application, 2, :status_submitted) }
      let(:status) { "shortlisted" }
      let(:origin) { "submitted" }
      let(:validate_all_attributes) { nil }

      describe "validation" do
        context "when validate_all_attributes evaluates to truthy" do
          let(:validate_all_attributes) { "false" }

          it { is_expected.to validate_length_of(:job_applications) }
          it { is_expected.to validate_presence_of(:status) }
          it { is_expected.to validate_inclusion_of(:status).in_array(%w[submitted unsuccessful reviewed shortlisted interviewing offered declined unsuccessful_interview]) }
        end

        context "when validate_all_attributes evaluates to falsey" do
          let(:validate_all_attributes) { nil }

          it { is_expected.to validate_length_of(:job_applications) }
          it { is_expected.not_to validate_presence_of(:status) }
        end
      end

      describe ".name" do
        it { expect(tag_form.name).to eq("TagForm") }
      end
    end
  end
end
