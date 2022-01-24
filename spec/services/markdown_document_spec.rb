require "rails_helper"

RSpec.describe MarkdownDocument do
  subject { described_class.new(section, post_name) }

  let(:section) { "get-help-hiring" }
  let(:post_name) { "document" }
  let(:file_path) { Rails.root.join("app", "views", "content", section, "#{post_name}.md") }
  let(:document_content) { file_fixture("document.md").read }
  let(:file_exists?) { true }

  before do
    allow(File).to receive(:exist?).with(file_path).and_return(file_exists?)
    allow(File).to receive(:read).with(file_path).and_return(document_content)
  end

  describe "#exist?" do
    context "when the file exists" do
      it "returns true" do
        expect(subject.exist?).to be true
      end
    end

    context "when the file does not exist" do
      let(:file_exists?) { false }

      it "returns false" do
        expect(subject.exist?).to be false
      end
    end
  end

  describe "#title" do
    it "returns the title" do
      expect(subject.title).to eq("Title")
    end
  end

  describe "#content" do
    let(:front_matter) { FrontMatterParser::Parser.new(:md).call(document_content) }
    let(:kramdown_document) { Kramdown::Document.new(front_matter.content) }

    it "returns the content" do
      expect(subject.content).to eq(kramdown_document.to_html)
    end
  end

  describe "#h2_headings" do
    it "returns an array of headings" do
      expect(subject.h2_headings).to eq(["First heading", "Second heading"])
    end
  end

  describe "#category_tags" do
    it "returns an array of category tags" do
      expect(subject.category_tags).to eq(["category 1", "category 2", "category 3"])
    end
  end

  describe "#date_posted" do
    context "when there is a date in the front matter" do
      it "returns a Date" do
        expect(subject.date_posted).to eq(Date.parse("01/01/2022"))
      end
    end

    context "when there is no date in the front matter" do
      let(:document_content) { file_fixture("document_no_front_matter.md").read }

      it "returns nil" do
        expect(subject.date_posted).to eq(nil)
      end
    end
  end

  describe "#meta_description" do
    it "returns the meta description" do
      expect(subject.meta_description).to eq("Meta description")
    end
  end

  describe ".all" do
    let(:dir_path) { Rails.root.join("app", "views", "content", section) }

    before { allow(Dir).to receive(:children).with(dir_path).and_return(%w[document.md]) }

    it "returns an array of markdown documents" do
      expect(described_class.all(section)).to eq([described_class.new(section, post_name)])
    end
  end

  describe "#order" do
    context "when order is defined" do
      it "returns the order" do
        expect(subject.order).to eq(1)
      end
    end

    context "when order is undefined" do
      let(:document_content) { file_fixture("document_no_front_matter.md").read }

      it "returns infinity" do
        expect(subject.order).to eq(Float::INFINITY)
      end
    end
  end
end
