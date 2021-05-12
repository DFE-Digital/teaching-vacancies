require "rails_helper"

RSpec.describe AbTest::CookiesBannerComponent, type: :component do
  let(:preferences_path) { "/pp" }
  let(:create_path) { "/cp" }
  let(:reject_path) { "/rp" }

  let!(:inline_component) { render_inline(described_class.new(create_path: create_path, reject_path: reject_path, preferences_path: preferences_path).with_variant(:top_static_default)) }

  it "renders the cookies banner component" do
    expect(inline_component.css(".cookies-banner-component").count).to eq(1)
  end
end
