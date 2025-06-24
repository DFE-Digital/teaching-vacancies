require "rails_helper"

RSpec.describe Jobseekers::JobApplications::QuickApply do
  subject { described_class.new(jobseeker, vacancy) }

  describe "#job_application" do
    context "when jobseeker has a recent job application" do
      let(:jobseeker) { double("Jobseeker") }
      let(:vacancy) { double("Vacancy") }
      let(:new_job_application) { double("NativeJobApplication") }
      let(:prefill_service) { double("Jobseekers::JobApplications::PrefillJobApplicationFromPreviousApplication") }

      before do
        allow(jobseeker).to receive_message_chain(:native_job_applications, :create!).and_return(new_job_application)
        allow(jobseeker).to receive_message_chain(:job_applications, :not_draft, :any?).and_return(true)
        allow(jobseeker).to receive(:jobseeker_profile).and_return(nil)
        allow(vacancy).to receive(:has_uploaded_form?).and_return(false)
      end

      it "prefills the new job application from the previous job application" do
        expect(Jobseekers::JobApplications::PrefillJobApplicationFromPreviousApplication).to receive(:new).with(jobseeker, new_job_application).and_return(prefill_service)
        expect(prefill_service).to receive(:call)

        subject.job_application
      end
    end

    context "when jobseeker does not have a recent job application but does have a jobseeker profile" do
      let(:jobseeker) { double("Jobseeker") }
      let(:vacancy) { double("Vacancy") }
      let(:new_job_application) { double("NativeJobApplication") }
      let(:prefill_service) { double("Jobseekers::JobApplications::PrefillJobApplicationFromJobseekerProfile") }

      before do
        allow(jobseeker).to receive_message_chain(:native_job_applications, :create!).and_return(new_job_application)
        allow(jobseeker).to receive_message_chain(:job_applications, :not_draft, :any?).and_return(false)
        allow(jobseeker).to receive(:jobseeker_profile).and_return(double("JobseekerProfile"))
        allow(vacancy).to receive(:has_uploaded_form?).and_return(false)
      end

      it "prefills the new job application from the jobseeker profile" do
        expect(Jobseekers::JobApplications::PrefillJobApplicationFromJobseekerProfile).to receive(:new).with(jobseeker, new_job_application).and_return(prefill_service)
        expect(prefill_service).to receive(:call)

        subject.job_application
      end
    end

    context "when vacancy has an uploaded application form" do
      let(:jobseeker) { create(:jobseeker) }
      let(:vacancy) { create(:vacancy) }

      before do
        allow(vacancy).to receive(:has_uploaded_form?).and_return(true)
      end

      it "creates a new draft job application for the new vacancy" do
        expect { subject.job_application }.to change { jobseeker.job_applications.draft.count }.by(1)
      end

      it "returns blank native job application" do
        job_application = subject.job_application
        expect(job_application.is_a?(UploadedJobApplication)).to be(true)
        expect(job_application.first_name).to be_blank
        expect(job_application.last_name).to be_blank
        expect(job_application.phone_number).to be_blank
        expect(job_application.has_right_to_work_in_uk).to be_nil
      end
    end

    context "when vacancy does not have an uploaded application form" do
      context "when jobseeker has neither a recent job application nor a jobseeker profile" do
        let(:jobseeker) { create(:jobseeker) }
        let(:vacancy) { create(:vacancy) }

        it "creates a new draft job application for the new vacancy" do
          expect { subject.job_application }.to change { jobseeker.job_applications.draft.count }.by(1)
        end

        it "returns blank native job application" do
          job_application = subject.job_application
          expect(job_application.is_a?(NativeJobApplication)).to be(true)
          expect(job_application.first_name).to be_blank
          expect(job_application.last_name).to be_blank
          expect(job_application.phone_number).to be_blank
          expect(job_application.qualified_teacher_status_year).to be_blank
          expect(job_application.qualified_teacher_status).to be_blank
          expect(job_application.has_right_to_work_in_uk).to be_nil
          expect(job_application.qualifications).to be_blank
          expect(job_application.employments).to be_blank
          expect(job_application.training_and_cpds).to be_blank
        end
      end
    end

    context "when vacancy"
  end
end
