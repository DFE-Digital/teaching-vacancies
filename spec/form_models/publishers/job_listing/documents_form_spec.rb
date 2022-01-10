require "rails_helper"

RSpec.describe Publishers::JobListing::DocumentsForm do
  describe "#valid_documents" do
    subject { described_class.new(documents:) }

    let(:valid_document) { double("Uploaded file", size: 9.99.megabytes, tempfile: valid_tempfile, original_filename: "file.pdf") }
    let(:too_large_document) { double("Uploaded file", size: 11.megabytes, original_filename: "file.pdf") }
    let(:invalid_mime_type_document) { double("Uploaded file", size: 8.megabytes, tempfile: invalid_mime_tempfile, original_filename: "file.pdf") }
    let(:infected_document) { double("Uploaded file", size: 4.megabytes, tempfile: virus_tempfile, original_filename: "file.pdf") }

    let(:valid_tempfile) { double("Tempfile") }
    let(:invalid_mime_tempfile) { double("Tempfile") }
    let(:virus_tempfile) { double("Tempfile") }

    before do
      allow(MimeMagic).to receive(:by_magic)
        .and_return(double(type: "application/pdf"))
      allow(MimeMagic).to receive(:by_magic)
        .with(invalid_mime_tempfile)
        .and_return(double(type: "application/nope"))

      allow(Publishers::DocumentVirusCheck).to receive(:new)
        .and_return(double(safe?: false))
      allow(Publishers::DocumentVirusCheck).to receive(:new)
        .with(valid_tempfile)
        .and_return(double(safe?: true))
    end

    let(:documents) do
      [
        valid_document,
        too_large_document,
        invalid_mime_type_document,
        infected_document,
      ]
    end

    it "only returns documents that pass validation" do
      expect(subject.valid_documents).to eq([valid_document])
    end
  end
end
