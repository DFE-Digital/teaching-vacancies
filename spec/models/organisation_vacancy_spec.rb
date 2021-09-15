require "rails_helper"

RSpec.describe OrganisationVacancy do
  context "when a vacancy is associated to an organisation" do
    let(:vacancy) { create(:vacancy, postcode_from_mean_geolocation: "A12 B34") }
    let(:school) { create(:school, geolocation: [3, 4], postcode: "C56 D78") }
    let!(:organisation_vacancy1) { OrganisationVacancy.create(organisation: school, vacancy: vacancy) }

    it "recalculates the vacancy's postcode_from_mean_geolocation" do
      expect(vacancy.postcode_from_mean_geolocation).to eq(school.postcode)
    end

    context "when a vacancy is dissociated from an organisation" do
      let(:school2) { create(:school, geolocation: [5, 6]) }

      before do
        OrganisationVacancy.create(organisation: school2, vacancy: vacancy)
        organisation_vacancy1.destroy!
      end

      it "recalculates the vacancy's postcode_from_mean_geolocation" do
        expect(vacancy.postcode_from_mean_geolocation).to eq(school2.postcode)
      end
    end
  end
end
