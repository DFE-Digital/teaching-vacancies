require "rails_helper"

RSpec.describe BannerButtonComponent, type: :component do
  let(:text) { "A cool button" }
  let(:href) { "/some-test-path" }
  let(:method) { :post }
  let(:params) { { key: "value" } }
  let(:icon) { "apply" }

  let(:kwargs) { { text: text, href: href, method: method, params: params, icon: icon } }

  describe "rendered component" do
    subject! { render_inline(described_class.new(**kwargs)) }

    it_behaves_like "a component that accepts custom classes"
    it_behaves_like "a component that accepts custom HTML attributes"

    it "renders the banner button" do
      expect(page).to have_css("form[method='post'][action='/some-test-path']", class: "banner-button-component") do |form|
        expect(form).to have_css("button[type='submit']", text: "A cool button", class: "banner-button-component__button icon icon--left icon--apply")
        expect(form).to have_css("input[type='hidden'][name='key'][value='value']", visible: false)
      end
    end
  end

  describe "#icon_class" do
    subject { described_class.new(**kwargs).send(:icon_classes) }

    context "when no icon is specified" do
      let(:icon) { nil }

      it "returns an empty array" do
        expect(subject).to be_empty
      end
    end

    context "when an invalid icon is specified" do
      let(:icon) { "invalid-icon" }

      it "raises an error" do
        expect { subject }.to raise_error(RuntimeError, /invalid icon/)
      end
    end
  end
end
