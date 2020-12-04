require "rails_helper"

RSpec.describe Shared::BannerLinkComponent, type: :component do
  let(:icon_class) { "test" }
  let(:link_id) { "test-id" }
  let(:link_path) { "#test" }
  let(:link_text) { "Click this link!" }

  before do
    render_inline(described_class.new(
                    icon_class: icon_class,
                    link_id: link_id,
                    link_method: link_method,
                    link_path: link_path,
                    link_text: link_text,
                  ))
  end

  context "when link_method is :get" do
    let(:link_method) { :get }

    it "renders the banner link" do
      expect(rendered_component).to eql(
        '<a class="banner-link icon icon--left icon--test" id="test-id" data-method="get" href="#test">'\
        '<div class="banner-link__text">Click this link!</div></a>',
      )
    end
  end

  context "when link_method is :post" do
    let(:link_method) { :post }

    it "renders the banner link" do
      expect(rendered_component).to eql(
        '<a class="banner-link icon icon--left icon--test" id="test-id" rel="nofollow" data-method="post" href="#test">'\
        '<div class="banner-link__text">Click this link!</div></a>',
      )
    end
  end
end
