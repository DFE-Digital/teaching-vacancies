require "rails_helper"

RSpec.describe OrganisationsHelper do
  describe "#required_profile_image" do
    subject(:required_profile_image) do
      helper.required_profile_image(image: image, missing_prompt: "Upload an image", alt_text: "School image")
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
