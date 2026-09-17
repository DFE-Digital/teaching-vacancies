require "rails_helper"

RSpec.describe FindAndUseAnApi::PublishCatalogue do
  let(:catalogue_entries) do
    [
      { "id" => "other-api", "name" => "some-other-api", "majorVersion" => "v1" },
      { "id" => "abc123", "name" => "teaching-vacancies-ats-api", "majorVersion" => "v1" },
    ]
  end

  before do
    allow(FauapiPublishing).to receive(:enabled?).and_return(true)
    allow(FindAndUseAnApi::Client).to receive(:import)
    allow(FindAndUseAnApi::Client).to receive(:publish)
    allow(FindAndUseAnApi::Client).to receive(:list_apis).and_return(catalogue_entries)
  end

  it "imports the manifest and publishes the matching catalogue entry" do
    expect(FindAndUseAnApi::Client).to receive(:import).with(hash_including(name: "teaching-vacancies-ats-api"))
    expect(FindAndUseAnApi::Client).to receive(:publish).with("abc123")

    described_class.call
  end

  context "when no catalogue entry matches after the import" do
    let(:catalogue_entries) { [{ "id" => "other-api", "name" => "some-other-api", "majorVersion" => "v1" }] }

    it "raises rather than publishing" do
      expect(FindAndUseAnApi::Client).not_to receive(:publish)

      expect { described_class.call }
        .to raise_error(described_class::Error, /No catalogue entry for teaching-vacancies-ats-api \(v1\)/)
    end
  end

  context "when more than one catalogue entry matches" do
    let(:catalogue_entries) do
      [
        { "id" => "abc123", "name" => "teaching-vacancies-ats-api", "majorVersion" => "v1" },
        { "id" => "def456", "name" => "teaching-vacancies-ats-api", "majorVersion" => "v1" },
      ]
    end

    it "raises rather than guessing which entry to publish" do
      expect(FindAndUseAnApi::Client).not_to receive(:publish)

      expect { described_class.call }
        .to raise_error(described_class::Error, /Ambiguous catalogue entries.*ids abc123, def456/)
    end
  end

  context "when publishing is disabled" do
    before { allow(FauapiPublishing).to receive(:enabled?).and_return(false) }

    it "makes no requests" do
      expect(FindAndUseAnApi::Client).not_to receive(:import)
      expect(FindAndUseAnApi::Client).not_to receive(:list_apis)
      expect(FindAndUseAnApi::Client).not_to receive(:publish)

      described_class.call
    end
  end
end
