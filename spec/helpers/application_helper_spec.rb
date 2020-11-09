require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#sanitize" do
    it "it sanitises the text" do
      html = "<p> a paragraph <a href='link'>with a link</a></p><br>"
      sanitized_html = "<p> a paragraph with a link</p><br>"

      expect(helper.sanitize(html)).to eq(sanitized_html)
    end
  end

  describe "#body_class" do
    before do
      expect(controller).to receive(:controller_name) { "foo" }
      expect(controller).to receive(:action_name) { "bar" }
      allow(controller).to receive(:authenticated?) { false }
    end

    it "returns the controller and action name" do
      expect(helper.body_class).to match(/foo_bar/)
    end

    it "does not return the authenticated class" do
      expect(helper.body_class).to_not match(/hiring-staff/)
    end

    context "when logged in" do
      before do
        expect(controller).to receive(:authenticated?) { true }
      end

      it "returns the authenticated class" do
        expect(helper.body_class).to match(/hiring-staff/)
      end
    end
  end

  describe "#recaptcha" do
    let(:request) { double("Request", content_security_policy_nonce: "n0nc3") }
    let(:captcha) { double("CAPTCHA") }

    before do
      allow(controller).to receive(:request).and_return(request)
      allow(helper).to receive(:recaptcha_v3).with(action: "hello_world", nonce: "n0nc3").and_return(captcha)
    end

    it "delegates to recaptcha_v3 with the CSP nonce" do
      expect(helper.recaptcha("hello_world")).to eq(captcha)
    end
  end
end
