require "rails_helper"

RSpec.describe SupportingDocumentComponent, type: :component do
  let(:supporting_document) { create(:document, size: 100_000) }
  let(:kwargs) { { supporting_document: supporting_document } }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  it "renders the document link" do
    expect(page).to have_css("div", class: "supporting-document-component") do |component|
      expect(component)
        .to have_css(
          "a[href='#{Rails.application.routes.url_helpers.document_path(supporting_document)}']",
          class: "supporting-document-component__link",
          text: supporting_document.name,
        )
    end
  end

  it "renders the document size in megabytes" do
    expect(page).to have_css("div", class: "supporting-document-component") do |component|
      expect(component).to have_content("0.10 MB")
    end
  end

  it "renders the document icon" do
    expect(page).to have_css("div", class: "supporting-document-component icon icon--left icon--document")
  end
end
