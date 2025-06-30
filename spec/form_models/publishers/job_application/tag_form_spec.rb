require "rails_helper"

module Publishers
  module JobApplication
    RSpec.describe TagForm, type: :model do
      subject(:tag_form) { described_class.new(job_applications:, status:, origin:) }

      let(:job_applications) { build_list(:job_application, 2) }
      let(:status) { "shortlisted" }
      let(:origin) { "shortlisted" }

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

      context "when context is update_tag" do
        it "when status missing invalid" do
          tag_form.status = nil
          tag_form.valid?(:update_tag)
          expect(tag_form.errors[:status]).to be_present
        end

        it "when status present valid" do
          tag_form.valid?(:update_tag)
          expect(tag_form.errors[:status]).to be_empty
        end
      end

      describe ".update_job_application_statuses" do
        subject { described_class.new(job_applications:, status:, origin:).update_job_application_statuses }

        context "when origin is shortlisted" do
          let(:origin) { "shortlisted" }

          it { is_expected.to eq(%i[unsuccessful interviewing offered]) }
        end

        context "when origin is interviewing" do
          let(:origin) { "interviewing" }

          it { is_expected.to eq(%i[unsuccessful offered]) }
        end

        context "when origin is any other" do
          let(:origin) { "reviewed" }

          it { is_expected.to eq(%i[reviewed unsuccessful shortlisted interviewing offered]) }
        end
      end
    end
  end
end
