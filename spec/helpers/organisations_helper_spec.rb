require "rails_helper"

RSpec.describe OrganisationsHelper do
  describe "#required_profile_image" do
    subject(:required_profile_image) do
      helper.required_profile_image(image: image, missing_prompt: "Upload an image", alt_text: "School image")
    end

    context "when an attached image has passed malware scanning" do
      let(:image) { double }

      before do
        allow(helper).to receive(:malware_scan_clean?).with(image).and_return(true)
        allow(helper).to receive(:image_tag).with(image, alt: "School image", class: "contained-image").and_return("<img alt=\"School image\" class=\"contained-image\">")
      end

      it "returns an image tag" do
        expect(required_profile_image).to include("img")
        expect(required_profile_image).to include("alt=\"School image\"")
        expect(required_profile_image).to include("class=\"contained-image\"")
      end
    end

    context "when an attached image has not passed malware scanning" do
      let(:image) { double(attached?: true, filename: "unsafe-image.png") }

      before do
        allow(helper).to receive(:malware_scan_clean?).with(image).and_return(false)
      end

      it "returns the filename instead of the image" do
        expect(required_profile_image).to eq("unsafe-image.png")
      end
    end
  end
end
