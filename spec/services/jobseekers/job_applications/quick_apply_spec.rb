require "rails_helper"

RSpec.describe Jobseekers::JobApplications::QuickApply do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy) }
  let(:new_vacancy) { create(:vacancy) }
  let!(:recent_job_application) { create(:job_application, :status_submitted, submitted_at: 1.day.ago, jobseeker:, vacancy:) }
  let!(:older_job_application) { create(:job_application, :status_submitted, submitted_at: 1.week.ago, jobseeker:, vacancy:) }
  let!(:draft_job_application) { create(:job_application, jobseeker:, vacancy:) }

  describe "#recent_job_application" do
    subject { described_class.new(jobseeker, new_vacancy).send(:recent_job_application) }

    it "returns the most recent non draft job application for the jobseeker" do
      expect(subject).to eq(recent_job_application)
    end
  end

  describe "#job_application" do
    subject { described_class.new(jobseeker, new_vacancy).job_application }

    it "creates a new draft job application for the new vacancy" do
      expect { subject }.to change { jobseeker.job_applications.draft.count }.by(1)
      expect(subject.vacancy).to eq(new_vacancy)
    end

    it "copies attributes" do
      attributes_to_copy = %i[
        first_name last_name previous_names street_address city country postcode phone_number teacher_reference_number national_insurance_number
        qualified_teacher_status qualified_teacher_status_year qualified_teacher_status_details statutory_induction_complete
        support_needed support_needed_details
      ]

      expect(subject.slice(*attributes_to_copy)).to eq(recent_job_application.slice(*attributes_to_copy))
    end

    it "copies completed steps" do
      expect(subject.completed_steps)
        .to eq(%w[personal_details professional_status qualifications employment_history references ask_for_support])
    end

    it "copies qualifications" do
      attributes_to_copy = %i[category finished_studying finished_studying_details grade institution name subject year]

      expect(subject.qualifications.map { |qualification| qualification.slice(*attributes_to_copy) })
        .to eq(recent_job_application.qualifications.map { |qualification| qualification.slice(*attributes_to_copy) })
    end

    it "copies employments" do
      attributes_to_copy = %i[organisation job_title subjects current_role main_duties started_on ended_on]

      expect(subject.employments.map { |employment| employment.slice(*attributes_to_copy) })
        .to eq(recent_job_application.employments.map { |employment| employment.slice(*attributes_to_copy) })
    end

    it "copies references" do
      attributes_to_copy = %i[name job_title organisation relationship email phone_number]

      expect(subject.references.map { |reference| reference.slice(*attributes_to_copy) })
        .to eq(recent_job_application.references.map { |reference| reference.slice(*attributes_to_copy) })
    end

    it "does not copy declarations attributes" do
      expect(subject.close_relationships).to be_blank
      expect(subject.close_relationships_details).to be_blank
      expect(subject.right_to_work_in_uk).to be_blank
    end

    it "does not copy equal opportunities attributes" do
      expect(subject.disability).to be_blank
      expect(subject.gender).to be_blank
      expect(subject.gender_description).to be_blank
      expect(subject.orientation).to be_blank
      expect(subject.orientation_description).to be_blank
      expect(subject.ethnicity).to be_blank
      expect(subject.ethnicity_description).to be_blank
      expect(subject.religion).to be_blank
      expect(subject.religion_description).to be_blank
    end

    it "does not copy personal statement" do
      expect(subject.personal_statement).to be_blank
    end
  end
end
