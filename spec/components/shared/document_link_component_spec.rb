require "rails_helper"

RSpec.describe Shared::DocumentLinkComponent, type: :component do
  let(:document) { build_stubbed(:document, size: 100_000) }

  before do
    render_inline(described_class.new(document: document))
  end

  it "renders the document link" do
    expect(rendered_component).to include("href=\"#{document.download_url}\"")
  end

  it "renders the document name" do
    expect(rendered_component).to include(document.name)
  end

  it "renders the document size in megabytes" do
    expect(rendered_component).to include("0.10 MB")
  end

  it "renders the document icon" do
    expect(rendered_component).to include("class=\"icon icon--left icon--document\"")
  end
end
