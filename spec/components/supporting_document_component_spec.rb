require "rails_helper"

RSpec.describe SupportingDocumentComponent, type: :component do
  let(:vacancy) { create(:vacancy) }
  let(:supporting_document) { double("ActiveStorage attachment", id: "abcde-12345", filename: "job_desc.doc", byte_size: 100_000, record: vacancy) }
  let(:kwargs) { { supporting_document: } }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  it "renders the document link" do
    expect(page).to have_css("div", class: "supporting-document-component") do |component|
      expect(component)
        .to have_css(
          "a[href='#{Rails.application.routes.url_helpers.job_document_path(vacancy, supporting_document)}']",
          class: "supporting-document-component__link",
          text: supporting_document.filename,
        )
    end
  end

  it "renders the document size in megabytes" do
    expect(page).to have_css("div", class: "supporting-document-component") do |component|
      expect(component).to have_content("97.7 KB")
    end
  end

  it "renders the document icon" do
    expect(page).to have_css("div", class: "supporting-document-component icon icon--left icon--document")
  end
end
