require "rails_helper"

RSpec.describe Employment do
  it { is_expected.to belong_to(:job_application).optional }
  it { is_expected.to belong_to(:jobseeker_profile).optional }

  describe "#duplicate" do
    subject(:duplicate) { employment.duplicate }
    let(:employment) { create(:employment) }

    it "returns a new Employment with the same attributes" do
      %i[
        current_role
        employment_type
        ended_on
        job_title
        main_duties
        organisation
        reason_for_break
        salary
        started_on
        subjects
      ].each do |attribute|
        expect(duplicate.public_send(attribute)).to eq(employment.public_send(attribute))
      end
    end

    it "returns a new unsaved Employment" do
      expect(duplicate).to be_new_record
    end

    it "does not copy job application associations" do
      expect(duplicate.job_application).to be_nil
    end

    it "does not copy jobseeker profile associations" do
      expect(duplicate.jobseeker_profile).to be_nil
    end
  end
end
