require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "#sanitize" do
    it "it sanitises the text" do
      html = "<p> a paragraph <a href='link'>with a link</a></p><br>"
      sanitized_html = "<p> a paragraph with a link</p><br>"

      expect(helper.sanitize(html)).to eq(sanitized_html)
    end
  end

  describe "#body_class" do
    before do
      expect(controller).to receive(:controller_path) { "foo/baz" }
      expect(controller).to receive(:action_name) { "bar" }
      allow(controller).to receive(:publisher_signed_in?) { false }
    end

    it "returns the controller and action name" do
      expect(helper.body_class).to match(/foo_baz_bar/)
    end

    it "does not return the authenticated class" do
      expect(helper.body_class).to_not match(/publisher/)
    end

    context "when logged in" do
      before do
        expect(controller).to receive(:publisher_signed_in?) { true }
      end

      it "returns the authenticated class" do
        expect(helper.body_class).to match(/publisher/)
      end
    end
  end

  describe "#recaptcha" do
    let(:request) { double("Request", content_security_policy_nonce: "n0nc3") }
    let(:captcha) { double("CAPTCHA") }

    before do
      allow(controller).to receive(:request).and_return(request)
      allow(controller).to receive(:controller_name).and_return("hello_world")
      allow(helper).to receive(:recaptcha_v3).with(action: "hello_world", nonce: "n0nc3").and_return(captcha)
    end

    it "delegates to recaptcha_v3 with the CSP nonce" do
      expect(helper.recaptcha).to eq(captcha)
    end
  end

  describe "#phase_banner_text" do
    subject { helper.phase_banner_text }
    let(:sandbox) { false }

    before do
      allow(Rails.configuration.app_role).to receive(:sandbox?).and_return(sandbox)
    end

    it { is_expected.to eq("beta") }

    context "sandbox" do
      let(:sandbox) { true }
      it { is_expected.to eq("sandbox") }
    end
  end
end
