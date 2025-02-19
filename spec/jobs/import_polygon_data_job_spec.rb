require "rails_helper"

RSpec.describe ImportPolygonDataJob do
  let(:importer) { double(call: nil) }

  describe "#perform" do
    it "calls the importers" do
      expect(OnsDataImport::ImportCounties).to receive(:call)
      expect(OnsDataImport::ImportCities).to receive(:call)
      expect(OnsDataImport::ImportRegions).to receive(:call)

      subject.perform
    end
  end
end
