require "rails_helper"

RSpec.describe SavedJobDecorator do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, enable_job_applications: true) }
  let(:saved_job) { create(:saved_job, vacancy: vacancy, jobseeker: jobseeker) }
  let(:decorator) { described_class.new(saved_job, jobseeker) }

  describe "#submitted_application" do
    context "when a submitted application exists for the vacancy" do
      let!(:application) { create(:job_application, :status_submitted, vacancy: vacancy, jobseeker: jobseeker) }

      it "returns the submitted application" do
        expect(decorator.submitted_application).to eq(application)
      end
    end

    context "when no submitted application exists" do
      it "returns nil" do
        expect(decorator.submitted_application).to be_nil
      end
    end

    it "memoizes the result" do
      create(:job_application, :status_submitted, vacancy: vacancy, jobseeker: jobseeker)
      expect(jobseeker).to receive(:job_applications).once.and_call_original
      decorator.submitted_application
      decorator.submitted_application
    end
  end

  describe "#draft_application" do
    context "when a draft application exists for the vacancy" do
      let!(:application) { create(:job_application, vacancy: vacancy, jobseeker: jobseeker) }

      it "returns the draft application" do
        expect(decorator.draft_application).to eq(application)
      end
    end

    context "when no draft application exists" do
      it "returns nil" do
        expect(decorator.draft_application).to be_nil
      end
    end

    it "memoizes the result" do
      create(:job_application, vacancy: vacancy, jobseeker: jobseeker)
      expect(jobseeker).to receive(:job_applications).once.and_call_original
      decorator.draft_application
      decorator.draft_application
    end
  end

  describe "#job_application" do
    context "when a submitted application exists" do
      let!(:application) { create(:job_application, :status_submitted, vacancy: vacancy, jobseeker: jobseeker) }

      it "returns the submitted application" do
        expect(decorator.job_application).to eq(application)
      end
    end

    context "when only a draft application exists" do
      let!(:application) { create(:job_application, vacancy: vacancy, jobseeker: jobseeker) }

      it "returns the draft application" do
        expect(decorator.job_application).to eq(application)
      end
    end

    context "when no application exists" do
      it "returns nil" do
        expect(decorator.job_application).to be_nil
      end
    end
  end

  describe "#action" do
    context "when the vacancy is not accepting applications" do
      let(:vacancy) { create(:vacancy, :expired, enable_job_applications: true) }

      it "returns nil" do
        expect(decorator.action).to be_nil
      end
    end

    context "when the vacancy is accepting applications" do
      context "when a submitted application exists" do
        before { create(:job_application, :status_submitted, vacancy: vacancy, jobseeker: jobseeker) }

        it "returns :view" do
          expect(decorator.action).to eq(:view)
        end
      end

      context "when only a draft application exists" do
        before { create(:job_application, vacancy: vacancy, jobseeker: jobseeker) }

        it "returns :continue" do
          expect(decorator.action).to eq(:continue)
        end
      end

      context "when no application exists" do
        it "returns :apply" do
          expect(decorator.action).to eq(:apply)
        end
      end
    end
  end
end
