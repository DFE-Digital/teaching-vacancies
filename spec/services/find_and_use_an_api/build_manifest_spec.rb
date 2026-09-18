require "rails_helper"

RSpec.describe FindAndUseAnApi::BuildManifest do
  subject(:manifest) { described_class.call }

  let(:spec_path) { Rails.root.join("swagger/v1/swagger.yaml") }

  it "describes the ATS API" do
    expect(manifest).to include(
      name: "teaching-vacancies-ats-api",
      displayName: "Teaching Vacancies ATS API",
      majorVersion: "v1",
      visibility: "Public",
      backendType: "http",
    )
  end

  it "declares both deployed environments" do
    expect(manifest[:environments].pluck(:name)).to contain_exactly("staging", "production")
    expect(manifest[:environments].pluck(:backendUrl))
      .to contain_exactly("https://staging.teaching-vacancies.service.gov.uk", "https://teaching-vacancies.service.gov.uk")
  end

  it "marks v1 as the current live release" do
    expect(manifest[:releases]).to eq([{ isCurrent: true, name: "v1", tag: "Live", notes: "Live release of the Teaching Vacancies ATS API." }])
  end

  describe "the embedded schema" do
    it "is the generated OpenAPI document, base64 encoded" do
      expect(manifest[:schema]).to include(fileName: "swagger.yaml", name: "v1", schemaType: "openapi", contentType: "application/yaml")
      expect(Base64.decode64(manifest[:schema][:documentContentValue])).to eq(File.binread(spec_path))
    end

    it "raises when the OpenAPI document has not been generated" do
      allow(File).to receive(:exist?).with(spec_path.to_s).and_return(false)

      expect { manifest }.to raise_error(described_class::Error, /No OpenAPI document at/)
    end
  end
end
