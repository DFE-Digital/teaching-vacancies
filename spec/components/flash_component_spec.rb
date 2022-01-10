require "rails_helper"

RSpec.describe FlashComponent, type: :component do
  let(:variant_name) { "notice" }
  let(:kwargs) { { variant_name:, message: "Some message" } }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  it "renders the flash" do
    expect(page).to have_css("div", class: "flash-component flash-component--notice icon icon--left icon--notice") do |flash|
      expect(flash).to have_css("a", class: "govuk-link govuk-link--no-visited-state js-dismissible js-dismissible__link", text: I18n.t("buttons.dismiss"))
      expect(flash).to have_css("div", class: "flash-component__content", text: "Some message")
    end
  end

  context "when variant is invalid" do
    let(:variant_name) { "invalid-variant" }

    it "does not render the flash" do
      expect(page).not_to have_css("div", class: "flash-component")
    end
  end
end
