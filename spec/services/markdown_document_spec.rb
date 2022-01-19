require "rails_helper"

RSpec.describe MarkdownDocument do
  subject { described_class.new(section, file_name) }

  let(:section) { "get-help-hiring" }
  let(:file_name) { "document" }
  let(:document_content) { file_fixture("document.md").read }
  let(:file_exists?) { true }

  before do
    expect(File).to receive(:file?).and_return(file_exists?)
    expect(File).to receive(:read).and_return(document_content)
    parsed = instance_double(FrontMatterParser::Parsed, front_matter: {}, content: "")
    expect(FrontMatterParser::Parser).to receive_message_chain(:new, :call).and_return(parsed)
    kramdown_document = instance_double(Kramdown::Document)
    expect(Kramdown::Document).to receive(:new).with(parsed.content).and_return(kramdown_document)
  end

  describe "#parse" do
    context "when the file exists" do
      it "returns an instance of the MarkdownDocument class" do
        expect(subject.parse).to be_an_instance_of(MarkdownDocument)
      end
    end

    context "when the file does not exist" do
      let(:file_exists?) { false }

      it "returns nil" do
        expect(subject.parse).to eq(nil)
      end
    end
  end

  describe "#title" do

  end

  describe "#content" do

  end

  describe "#h2_heading" do

  end
end
