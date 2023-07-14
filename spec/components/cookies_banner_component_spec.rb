require "rails_helper"

RSpec.describe CookiesBannerComponent, type: :component do
  let(:preferences_path) { "/pp" }
  let(:accept_path) { "/cp" }
  let(:reject_path) { "/rp" }

  let(:kwargs) { { accept_path: accept_path, reject_path: reject_path, preferences_path: preferences_path } }

  let!(:inline_component) { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  it "renders 3 actions for user" do
    expect(inline_component.css(".button_to").count).to eq(2)
    expect(inline_component.css(".button_to:first-child").attribute("action").value).to eq(accept_path)
    expect(inline_component.css(".button_to:nth-child(2)").attribute("action").value).to eq(reject_path)

    expect(inline_component.css(".govuk-link").count).to eq(1)
    expect(inline_component.css(".govuk-link").attribute("href").value).to eq(preferences_path)
  end
end
