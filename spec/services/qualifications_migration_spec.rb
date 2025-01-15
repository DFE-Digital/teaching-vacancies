require "rails_helper"

RSpec.describe QualificationsMigration, type: :model do
  let!(:profile) { create(:jobseeker_profile) }
  let!(:application) { create(:job_application) }

  let!(:profile_qualification) { create(:qualification, category: "other_secondary", jobseeker_profile: profile, job_application: nil) }
  let!(:application_qualification) { create(:qualification, category: "other_secondary", job_application: application, jobseeker_profile: nil) }
  let!(:unrelated_qualification) { create(:qualification, category: "a_level") }

  before do
    profile_qualification.qualification_results.destroy_all
    application_qualification.qualification_results.destroy_all

    QualificationResult.create!(qualification: profile_qualification, subject: "Science", grade: "A")
    QualificationResult.create!(qualification: application_qualification, subject: "History", grade: "B")
  end

  describe ".perform" do
    it "migrates qualifications with category other_secondary to other" do
      expect {
        described_class.perform
      }.to change { Qualification.where(category: "other").count }.by(2)
    end

    it "creates new qualifications with the correct attributes" do
      described_class.perform
      new_qualifications = Qualification.where(category: "other")

      expect(new_qualifications.count).to eq(2)
      expect(new_qualifications.pluck(:subject)).to contain_exactly("Science", "History")
      expect(new_qualifications.pluck(:grade)).to contain_exactly("A", "B")
    end

    it "ensures new qualifications maintain their associations" do
      described_class.perform

      profile_other_qualification = Qualification.find_by(subject: "Science", category: "other")
      application_other_qualification = Qualification.find_by(subject: "History", category: "other")

      expect(profile_other_qualification.jobseeker_profile).to eq(profile)
      expect(profile_other_qualification.job_application).to be_nil

      expect(application_other_qualification.job_application).to eq(application)
      expect(application_other_qualification.jobseeker_profile).to be_nil
    end

    it "deletes the original qualifications with category other_secondary" do
      expect {
        described_class.perform
      }.to change { Qualification.where(category: "other_secondary").count }.by(-2)
    end

    it "does not change other qualification types" do
      expect {
        described_class.perform
      }.not_to(change { Qualification.where(category: "a_level").count })

      unaffected_qualification = Qualification.find_by(id: unrelated_qualification.id)
      expect(unaffected_qualification).to be_present
      expect(unaffected_qualification.category).to eq("a_level")
    end

    context "when an error occurs during migration" do
      before do
        allow(Qualification).to receive(:create!).and_raise(StandardError, "Test error")
      end

      it "logs the error and does not delete original qualifications" do
        expect(Rails.logger).to receive(:error).with(/Error migrating qualifications: Test error/)
        expect {
          begin
            described_class.perform
          rescue StandardError
            nil
          end
        }.not_to(change { Qualification.where(category: "other_secondary").count })
      end
    end
  end
end
