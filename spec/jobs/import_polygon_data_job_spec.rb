require "rails_helper"

RSpec.describe ImportPolygonDataJob do
  let(:importer) { double(call: nil) }

  describe "#perform" do
    it "calls the importers" do
      expect(OnsDataImport::ImportCounties).to receive(:new).and_return(importer)
      expect(OnsDataImport::ImportCities).to receive(:new).and_return(importer)
      expect(OnsDataImport::ImportRegions).to receive(:new).and_return(importer)

      subject.perform
      expect(importer).to have_received(:call).exactly(3).times
    end
  end
end
