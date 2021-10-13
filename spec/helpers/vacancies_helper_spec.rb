require "rails_helper"

RSpec.describe VacanciesHelper do
  describe "#back_to_manage_jobs_link" do
    let(:vacancy) { double("vacancy").as_null_object }

    before do
      allow(vacancy).to receive(:listed?).and_return(false)
      allow(vacancy).to receive(:published?).and_return(false)
      allow(vacancy).to receive_message_chain(:expires_at, :future?).and_return(false)
    end

    it "returns draft jobs link for draft jobs" do
      expect(back_to_manage_jobs_link(vacancy)).to eq(jobs_with_type_organisation_path("draft"))
    end

    it "returns pending jobs link for scheduled jobs" do
      allow(vacancy).to receive(:published?).and_return(true)
      allow(vacancy).to receive_message_chain(:expires_at, :future?).and_return(true)
      expect(back_to_manage_jobs_link(vacancy)).to eq(jobs_with_type_organisation_path("pending"))
    end

    it "returns published jobs link for published jobs" do
      allow(vacancy).to receive(:listed?).and_return(true)
      expect(back_to_manage_jobs_link(vacancy)).to eq(jobs_with_type_organisation_path("published"))
    end

    it "returns expired jobs link for expired jobs" do
      allow(vacancy).to receive(:published?).and_return(true)
      allow(vacancy).to receive_message_chain(:expires_at, :past?).and_return(true)
      expect(back_to_manage_jobs_link(vacancy)).to eq(jobs_with_type_organisation_path("expired"))
    end
  end

  describe "#vacancy_full_job_location" do
    subject { vacancy_full_job_location(vacancy) }

    context "when job_location is at_multiple_schools" do
      let(:trust) { build(:trust, name: "Magic Trust") }
      let(:vacancy) { build(:vacancy, :at_multiple_schools, organisations: [trust]) }

      it "returns the multiple schools location" do
        expect(subject).to eq("More than one school, Magic Trust")
      end
    end

    context "when job_location is not at_multiple_schools" do
      let(:school) { build(:school, name: "Magic School", town: "Cool Town", county: "Orange County", postcode: "SW1A") }
      let(:vacancy) { build(:vacancy, organisations: [school]) }

      it "returns the full location" do
        expect(subject).to eq("Magic School, Cool Town, Orange County, SW1A")
      end
    end
  end
end
