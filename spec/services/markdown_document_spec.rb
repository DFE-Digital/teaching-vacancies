require "rails_helper"

RSpec.describe MarkdownDocument do
  subject { described_class.new(section, file_name) }

  let(:section) { "get-help-hiring" }
  let(:file_name) { "document" }
  let(:file_path) { Rails.root.join("app", "views", "content", section, "#{file_name}.md")}
  let(:document_content) { file_fixture("document.md").read }
  let(:file_exists?) { true }

  before do
    expect(File).to receive(:file?).with(file_path).and_return(file_exists?)
    allow(File).to receive(:read).with(file_path).and_return(document_content)
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
    before { subject.parse }

    it "returns the title" do
      expect(subject.title).to eq("Title")
    end
  end

  describe "#content" do
    let(:content) { Kramdown::Document.new(FrontMatterParser::Parser.new(:md).call(document_content).content).to_html }

    before { subject.parse }

    it "returns the content" do
      expect(subject.content).to eq(content)
    end
  end

  describe "#h2_heading" do
    before { subject.parse }

    it "returns an array of headings" do
      expect(subject.h2_headings).to eq(["First heading", "Second heading"])
    end
  end

  describe "#category_tags" do
    before { subject.parse }

    it "returns an array of category tags" do
      expect(subject.category_tags).to eq(["category 1", "category 2", "category 3"])
    end
  end

  describe "#date_posted" do
    before { subject.parse }

    it "returns the date posted as a string" do
      expect(subject.date_posted).to eq("01/01/2022")
    end
  end

  describe "#meta_description" do
    before { subject.parse }

    it "returns the meta description" do
      expect(subject.meta_description).to eq("Meta description")
    end
  end
end
