require "rails_helper"

RSpec.describe Jobseekers::JobApplicationsHelper, type: :helper do
  describe "#application_link_path" do
    let(:vacancy) { create(:vacancy) }

    before do
      allow(@vacancy).to receive(:id).and_return(vacancy.id)
    end

    context "when the jobseeker is signed in" do
      let(:jobseeker) { create(:jobseeker) }

      before do
        allow(helper).to receive(:current_jobseeker).and_return(jobseeker)
      end

      context "when the jobseeker has not applied for the job" do
        before do
          allow(jobseeker).to receive_message_chain(:job_applications, :find_by).and_return(nil)
        end

        let(:new_job_application_path) { new_jobseekers_job_job_application_path(vacancy.id) }

        it "returns the new job application path" do
          expect(helper.application_link_path).to eq(new_job_application_path)
        end
      end

      context "when the jobseeker has applied for the job" do
        let(:job_application) { create(:job_application) }
        let(:jobseeker) { job_application.jobseeker }
        let(:vacancy) { job_application.vacancy }
 
        before do
          allow(jobseeker).to receive_message_chain(:job_applications, :find_by).and_return(job_application)
        end

        context "when the job application has been submitted" do
          before do
            allow(job_application).to receive(:status).and_return("submitted")
          end

          let(:job_application_show_path) { jobseekers_job_application_path(job_application) }

          it "returns the job application show path" do
            expect(helper.application_link_path).to eq(job_application_show_path)
          end
        end

        context "when the job application is in draft" do
          before do
            allow(job_application).to receive(:status).and_return("draft")
          end

          let(:job_application_review_path) { jobseekers_job_application_review_path(job_application) }

          it "returns the job application review path" do
            expect(helper.application_link_path).to eq(job_application_review_path)
          end
        end
      end
    end

    context "when the jobseeker is signed out" do
      let(:new_job_application_path) { new_jobseekers_job_job_application_path(@vacancy.id) }

      before do
        allow(helper).to receive(:current_jobseeker).and_return(nil)
      end

      it "returns the new job application path" do
        expect(helper.application_link_path).to eq(new_job_application_path)
      end
    end
  end

  # TODO: - Below

  describe "#application_link_text" do
    let(:job_application) { create(:job_application, :status_submitted) }
    let(:translation_key) { "apply" }

    context "when the jobseeker is not signed in" do
      it 'returns "apply"' do
        expect(helper.application_link_text).to eq(translation_key)
      end
    end

    context "when the jobseeker is signed in" do
      context "when the jobseeker has not applied for the job" do
        it 'returns "apply"' do
          expect(helper.application_link_text).to eq(translation_key)
        end
      end

      context "when the application has been submitted" do
        let(:translation_key) { "submitted" }
        it 'returns "submitted"' do
          expect(helper.application_link_text).to eq(translation_key)
        end
      end

      context "when the application is in draft" do
        let(:translation_key) { "draft" }
        it 'returns "draft"' do
          expect(helper.application_link_text).to eq(translation_key)
        end
      end
    end
  end

  describe "#jobseeker_has_applied?" do
    let(:job_application) { create(:job_application, :status_submitted) }

    context "when a jobseeker is not signed in" do
      it "returns nil" do
      end
    end

    context "when a jobseeker is signed in" do
      context "when they have applied" do
        it "returns true" do
        end
      end

      context "when they have not applied" do
        it "returns false" do
        end
      end
    end
  end
end
