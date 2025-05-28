require "rails_helper"

class DummyWithinUnitedKingdomModel
  include ActiveModel::Model

  validates :location, within_united_kingdom: true

  attr_accessor :location
end

RSpec.describe WithinUnitedKingdomValidator do
  subject(:dummy) { DummyWithinUnitedKingdomModel.new(location: "Location") }

  before do
    allow(Geocoding).to receive(:new).with("Location").and_return(geocoding)
  end

  context "when location is within the United Kingdom" do
    let(:geocoding) { instance_double(Geocoding, uk_coordinates?: true) }

    it "is valid" do
      expect(dummy).to be_valid
    end
  end

  context "when location is not within the United Kingdom" do
    let(:geocoding) { instance_double(Geocoding, uk_coordinates?: false) }

    it "is not valid" do
      expect(dummy).not_to be_valid
    end

    it "adds an error message" do
      dummy.valid?
      expect(dummy.errors[:location])
        .to include(I18n.t("activemodel.errors.models.jobseekers/job_preferences_form/location_form.attributes.location.blank"))
    end
  end
end
