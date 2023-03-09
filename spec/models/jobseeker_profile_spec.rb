require "rails_helper"

RSpec.describe JobseekerProfile, type: :model do
  describe ".prepare(jobseeker:)" do
    subject(:profile) { described_class.prepare(jobseeker:) }
    let(:jobseeker) { create(:jobseeker) }

    context "when a profile already exists for that jobseeker" do
      let!(:existing_profile) { create(:jobseeker_profile, jobseeker:) }

      it "returns the existing profile" do
        expect(profile).to eq(existing_profile)
      end
    end

    context "when the jobseeker has a previous application" do
      let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:) }

      it "uses the details from the previous application" do
        expect(profile.employments.map(&:job_title).sort).to eq(previous_application.employments.map(&:job_title).sort)
        expect(profile.qualifications.map(&:institution).sort).to eq(previous_application.qualifications.map(&:institution).sort)
        expect(profile.qualified_teacher_status_year).to eq(previous_application.qualified_teacher_status_year)
        expect(profile.qualified_teacher_status).to eq(previous_application.qualified_teacher_status)
        expect(profile.personal_details.first_name).to eq(previous_application.first_name)
      end

      it "creates a job preferences record" do
        expect(profile.job_preferences).to be_present
      end
    end

    context "when the jobseeker has no previous application" do
      it "does not use the details from the previous application" do
        expect(profile.employments).to be_empty
        expect(profile.qualifications).to be_empty
        expect(profile.qualified_teacher_status_year).to be_nil
        expect(profile.qualified_teacher_status).to be_nil
      end

      it "still creates a personal details record" do
        expect(profile.personal_details).to be_present
      end

      it "still creates a job preferences record" do
        expect(profile.job_preferences).to be_present
      end
    end
  end
end
