require "rails_helper"

class DummyWithinUnitedKingdomModel
  include ActiveModel::Model

  validates :location, within_united_kingdom: true

  attr_accessor :location
end

RSpec.describe WithinUnitedKingdomValidator do
  subject(:dummy) { DummyWithinUnitedKingdomModel.new(location: location) }

  before do
    allow(Geocoding).to receive(:new).with(location).and_return(geocoding)
  end

  context "when location is within the United Kingdom" do
    let(:location) { "London" }
    let(:geocoding) { instance_double(Geocoding, coordinates: [51.5074, -0.1278]) }

    it "is valid" do
      expect(dummy).to be_valid
    end
  end

  context "when location returns no coordinates" do
    let(:location) { "Madrid" }
    let(:geocoding) { instance_double(Geocoding, coordinates: Geocoding::COORDINATES_NO_MATCH) }

    it "is not valid" do
      expect(dummy).not_to be_valid
    end

    it "adds an error message" do
      dummy.valid?
      expect(dummy.errors[:location])
        .to include(I18n.t("activemodel.errors.models.jobseekers/job_preferences_form/location_form.attributes.location.blank"))
    end
  end

  context "when the location returns the default GB centroid coordinates" do
    context "when the provided location is outside the UK" do
      let(:location) { "Madrid" }
      let(:geocoding) { instance_double(Geocoding, coordinates: Geocoding::COORDINATES_UK_CENTROID) }

      it "is not valid" do
        expect(dummy).not_to be_valid
      end

      it "adds an error message" do
        dummy.valid?
        expect(dummy.errors[:location])
          .to include(I18n.t("activemodel.errors.models.jobseekers/job_preferences_form/location_form.attributes.location.blank"))
      end
    end

    (described_class::UK_NAMES + ["U.K.", "G.B.", "U.K", "G.B"]).each do |uk_name|
      context "when the location is '#{uk_name}'" do
        let(:location) { uk_name }
        let(:geocoding) { instance_double(Geocoding, coordinates: Geocoding::COORDINATES_UK_CENTROID) }

        it "is valid" do
          expect(dummy).to be_valid
        end
      end
    end
  end
end
