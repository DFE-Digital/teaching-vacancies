require "rails_helper"

RSpec.describe JobLocationForm, type: :model do
  let(:job_location_form) { described_class.new(job_location: job_location) }

  describe "validations" do
    describe "#job_location" do
      context "when job location is blank" do
        let(:job_location) { nil }

        it "requests an entry in the field" do
          expect(job_location_form.valid?).to be false
          expect(job_location_form.errors.messages[:job_location]).to include(
            I18n.t("activemodel.errors.models.job_location_form.attributes.job_location.blank"),
          )
        end
      end
    end
  end

  context "when all attributes are valid" do
    let(:job_location) { "central_office" }

    it "a JobLocationForm can be converted to a vacancy" do
      expect(job_location_form.valid?).to be true
      expect(job_location_form.vacancy.job_location).to eql("central_office")
    end
  end
end
