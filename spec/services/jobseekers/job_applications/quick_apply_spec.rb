require "rails_helper"

RSpec.describe Jobseekers::JobApplications::QuickApply do
  subject { described_class.new(jobseeker, vacancy) }

  describe "#job_application" do
    context "when jobseeker has only a previously submitted native job application" do
      let(:jobseeker) { double("Jobseeker") }
      let(:vacancy) { double("Vacancy") }
      let(:new_job_application) { double("NativeJobApplication") }
      let(:prefill_service) { double("Jobseekers::JobApplications::PrefillJobApplicationFromPreviousApplication") }

      before do
        allow(vacancy).to receive(:uploaded_form?).and_return(false)
        allow(vacancy).to receive(:create_job_application_for).with(jobseeker).and_return(new_job_application)
        allow(jobseeker).to receive_messages(has_submitted_native_job_application?: true, jobseeker_profile: nil)
      end

      it "prefills the new job application from the previous job application" do
        expect(Jobseekers::JobApplications::PrefillJobApplicationFromPreviousApplication).to receive(:new).with(jobseeker, new_job_application).and_return(prefill_service)
        expect(prefill_service).to receive(:call)

        subject.job_application
      end
    end

    context "when jobseeker has only a previously submitted uploaded job application" do
      let(:jobseeker) { create(:jobseeker) }
      let(:vacancy) { create(:vacancy) }
      let(:uploaded_vacancy) { create(:vacancy) }

      before do
        create(:uploaded_job_application, :status_submitted, jobseeker: jobseeker, vacancy: uploaded_vacancy,
                                                             first_name: "Jane", last_name: "Smith", phone_number: "9876543210")
      end

      it "creates blank native job application" do
        job_application = subject.job_application
        expect(job_application.is_a?(NativeJobApplication)).to be(true)
        expect(job_application.first_name).to be_blank
        expect(job_application.last_name).to be_blank
        expect(job_application.phone_number).to be_blank
      end
    end

    context "when jobseeker has both a previous native job application and an uploaded job application but most recent is the uploaded job application" do
      let(:jobseeker) { create(:jobseeker) }
      let(:vacancy) { create(:vacancy) }
      let(:old_native_vacancy) { create(:vacancy) }
      let(:recent_uploaded_vacancy) { create(:vacancy) }

      before do
        create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: old_native_vacancy,
                                                    first_name: "John", last_name: "Doe", phone_number: "1234567890",
                                                    created_at: 2.weeks.ago, updated_at: 2.weeks.ago)

        create(:uploaded_job_application, :status_submitted, jobseeker: jobseeker, vacancy: recent_uploaded_vacancy,
                                                             first_name: "Jane", last_name: "Smith", phone_number: "9876543210",
                                                             created_at: 1.day.ago, updated_at: 1.day.ago)
      end

      it "prefills the new job application from the previous native job application, not the uploaded one" do
        job_application = subject.job_application

        expect(job_application.first_name).to eq("John")
        expect(job_application.last_name).to eq("Doe")
        expect(job_application.phone_number).to eq("1234567890")
      end
    end

    context "when jobseeker does not have a previous native job application but does have a jobseeker profile" do
      let(:jobseeker) { double("Jobseeker") }
      let(:vacancy) { double("Vacancy") }
      let(:new_job_application) { double("NativeJobApplication") }
      let(:prefill_service) { double("Jobseekers::JobApplications::PrefillJobApplicationFromJobseekerProfile") }

      before do
        allow(vacancy).to receive(:uploaded_form?).and_return(false)
        allow(vacancy).to receive(:create_job_application_for).with(jobseeker).and_return(new_job_application)
        allow(jobseeker).to receive_messages(has_submitted_native_job_application?: false, jobseeker_profile: double("JobseekerProfile"))
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
        allow(vacancy).to receive(:uploaded_form?).and_return(true)
      end

      it "creates a new draft job application for the new vacancy" do
        expect { subject.job_application }.to change { jobseeker.job_applications.draft.count }.by(1)
      end

      it "returns blank native job application" do
        job_application = subject.job_application
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
  end
end
