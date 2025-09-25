require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "#sanitize" do
    it "converts HTML entities back to normal characters" do
      html = "<p>AT&amp;T is a company</p>"
      sanitized_html = "<p>AT&T is a company</p>"

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
end
