require "rails_helper"

RSpec.describe VacanciesHelper do
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
