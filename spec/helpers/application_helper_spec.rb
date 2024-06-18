require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "#sanitize" do
    it "sanitises the text" do
      html = "<p> a paragraph <a href='link'>with a link</a></p><br>"
      sanitized_html = "<p> a paragraph with a link</p><br>"

      expect(helper.sanitize(html)).to eq(sanitized_html)
    end
  end

  describe "#body_class" do
    before do
      expect(controller).to receive(:controller_path).and_return("foo/baz")
      expect(controller).to receive(:action_name).and_return("bar")
      allow(controller).to receive(:publisher_signed_in?).and_return(false)
    end

    it "returns the controller and action name" do
      expect(helper.body_class).to match(/foo_baz_bar/)
    end

    it "does not return the authenticated class" do
      expect(helper.body_class).not_to match(/publisher/)
    end

    context "when logged in" do
      before do
        expect(controller).to receive(:publisher_signed_in?).and_return(true)
      end

      it "returns the authenticated class" do
        expect(helper.body_class).to match(/publisher/)
      end
    end
  end
end
