require "rails_helper"
require "pdf/inspector"

RSpec.describe PdfUiHelper do
  subject(:pdf) { PDF::Inspector::Text.analyze(instance.document.render).strings }

  let(:described_class) do
    Class.new do
      include Prawn::View
      include PdfUiHelper

      def document
        @document ||= Prawn::Document.new(page_size: "A4", margin: 1.cm)
      end
    end
  end

  let(:instance) { described_class.new }

  describe ".page_header" do
    let(:some_text) { "mighty page header" }

    before do
      instance.page_header { instance.text(some_text) }
    end

    it { is_expected.to include(some_text) }
  end

  describe ".page_footer" do
    let(:some_text) { "mighty page footer" }

    before { instance.page_footer(some_text) }

    it { is_expected.to include(some_text) }

    context "when multiple pages" do
      before do
        instance.text("blah blah")
        instance.start_new_page
        instance.text("blah blah")
      end

      it { is_expected.to include(some_text, some_text) }
    end
  end

  describe ".page_title" do
    let(:some_text) { "some title" }

    before { instance.page_title(some_text) }

    it { is_expected.to include(some_text) }
  end

  describe ".page_sub_title" do
    let(:some_text) { "some sub title" }

    before { instance.page_sub_title(some_text) }

    it { is_expected.to include(some_text) }
  end

  describe ".page_table" do
    let(:row_one) { ["heading 1", "value 1"] }
    let(:row_two) { ["heading 2", 23_132] }
    let(:data) { [row_one, row_two] }

    before { instance.page_table(data) }

    it { is_expected.to include(*row_one) }
    it { is_expected.to include(*row_two.map(&:to_s)) }
  end
end
