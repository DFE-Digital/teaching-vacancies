require "rails_helper"

RSpec.describe Shared::BannerLinkComponent, type: :component do
  let(:icon_class) { "test" }
  let(:link_id) { "test-id" }
  let(:link_path) { "#test" }
  let(:link_text) { "Click this link!" }
  let(:params) { nil }

  before do
    render_inline(described_class.new(
                    icon_class: icon_class,
                    link_id: link_id,
                    link_method: link_method,
                    link_path: link_path,
                    link_text: link_text,
                    params: params,
                  ))
  end

  context "when link_method is :get" do
    let(:link_method) { :get }

    it "renders the banner link" do
      expect(rendered_component).to eq(
        '<form class="banner-link-component" method="get" action="#test">'\
        '<input class="banner-link-component__button icon icon--left icon--test" id="test-id" type="submit" value="Click this link!" />'\
        "</form>",
      )
    end

    context "when params are provided" do
      let(:params) { { some_param: "test" } }

      it "renders the banner link" do
        expect(rendered_component).to eq(
          '<form class="banner-link-component" method="get" action="#test">'\
          '<input class="banner-link-component__button icon icon--left icon--test" id="test-id" type="submit" value="Click this link!" />'\
          '<input type="hidden" name="some_param" value="test" />'\
          "</form>",
        )
      end
    end
  end

  context "when link_method is :post" do
    let(:link_method) { :post }

    it "renders the banner link" do
      expect(rendered_component).to eq(
        '<form class="banner-link-component" method="post" action="#test">'\
        '<input class="banner-link-component__button icon icon--left icon--test" id="test-id" type="submit" value="Click this link!" />'\
        "</form>",
      )
    end
  end
end
