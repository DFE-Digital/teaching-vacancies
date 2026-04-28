require "rails_helper"

RSpec.describe Jobseekers::JobApplication::ReviewForm, type: :model do
  let(:completed_steps) { [] }
  let(:all_steps) { %w[personal_details professional_status employment_history] }

  subject do
    described_class.new({ confirm_data_accurate: "1", confirm_data_usage: "1", completed_steps: completed_steps, all_steps: all_steps })
  end

  it { is_expected.to validate_acceptance_of(:confirm_data_accurate) }
  it { is_expected.to validate_acceptance_of(:confirm_data_usage) }

  context "when all steps are complete" do
    let(:completed_steps) { JobApplication.completed_steps.keys }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "when there are incomplete steps" do
    let(:completed_steps) { %w[personal_details professional_status] }
    let(:incomplete_steps) { %i[employment_history] }

    it "is invalid" do
      expect(subject).not_to be_valid
      incomplete_steps.each do |incomplete_step|
        expect(subject.errors.messages_for(:base))
          .to include(I18n.t("activemodel.errors.models.jobseekers/job_application/pre_submit_form.#{incomplete_step}.incomplete"))
      end
    end
  end

  context "when job_application is an UploadedJobApplication" do
    let(:job_application) { create(:uploaded_job_application, :with_uploaded_application_form) }

    subject do
      described_class.new({
        confirm_data_accurate: "1",
        confirm_data_usage: "1",
        completed_steps: job_application.completed_steps,
        all_steps: all_steps,
        job_application: job_application,
      })
    end

    context "when the application form blob is pending" do
      before { job_application.application_form.blob.update!(metadata: {}) }

      it "is invalid and shows a pending message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages_for(:base)).to include(
          I18n.t("jobs.file_pending_scan_message", filename: job_application.application_form.filename),
        )
      end
    end

    context "when the application form blob is malicious" do
      before { job_application.application_form.blob.update!(metadata: { "malware_scan_result" => "malicious" }) }

      it "is invalid and shows an unsafe message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages_for(:base)).to include(
          I18n.t("jobs.file_unsafe_error_message", filename: job_application.application_form.filename),
        )
      end
    end

    context "when the application form blob is clean" do
      it "is valid with respect to the scan check" do
        expect(subject.errors.messages_for(:base)).not_to include(
          I18n.t("jobs.file_unsafe_error_message", filename: job_application.application_form.filename),
        )
      end
    end
  end
end
