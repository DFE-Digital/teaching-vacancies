require "rails_helper"

RSpec.describe OrganisationVacancy do
  context "when a vacancy is associated to an organisation" do
    let(:vacancy) { create(:vacancy, mean_geolocation: [1, 2]) }
    let(:school) { create(:school, geolocation: [3, 4]) }
    let!(:organisation_vacancy1) { OrganisationVacancy.create(organisation: school, vacancy: vacancy) }

    it "recalculates the vacancy's mean geolocation" do
      expect(vacancy.mean_geolocation).to eq(school.geolocation)
    end

    context "when it is dissociated from an organisation" do
      let(:school2) { create(:school, geolocation: [5, 6]) }

      before do
        OrganisationVacancy.create(organisation: school2, vacancy: vacancy)
        organisation_vacancy1.destroy!
      end

      it "recalculates the vacancy's mean geolocation" do
        expect(vacancy.mean_geolocation).to eq(school2.geolocation)
      end
    end
  end
end
