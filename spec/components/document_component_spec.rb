require "rails_helper"

RSpec.describe DocumentComponent, type: :component do
  let(:document) { create(:document, size: 100_000) }
  let(:kwargs) { { document: document } }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  it "renders the document link" do
    expect(page).to have_css("div", class: "document-component") do |component|
      expect(component)
        .to have_css(
          "a[href='#{Rails.application.routes.url_helpers.document_path(document)}']",
          class: "document-component__link",
          text: document.name,
        )
    end
  end

  it "renders the document size in megabytes" do
    expect(page).to have_css("div", class: "document-component") do |component|
      expect(component).to have_content("0.10 MB")
    end
  end

  it "renders the document icon" do
    expect(page).to have_css("div", class: "document-component icon icon--left icon--document")
  end
end
