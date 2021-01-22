require "rails_helper"

RSpec.describe Publishers::JobListing::JobLocationForm, type: :model do
  subject { described_class.new(job_location: job_location) }

  describe "validations" do
    describe "#job_location" do
      context "when job location is blank" do
        let(:job_location) { nil }

        it "requests an entry in the field" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:job_location]).to include(I18n.t("job_location_errors.job_location.blank"))
        end
      end
    end
  end

  context "when all attributes are valid" do
    let(:job_location) { "central_office" }

    it "a JobLocationForm can be converted to a vacancy" do
      expect(subject.valid?).to be true
      expect(subject.vacancy.job_location).to eq("central_office")
    end
  end
end
