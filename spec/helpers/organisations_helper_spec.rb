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

  describe "#organisation_label" do
    context "when the organisation is a college" do
      let(:organisation) { build_stubbed(:college) }

      it "returns 'College'" do
        expect(helper.organisation_label(organisation)).to eq("College")
      end
    end

    context "when the organisation is a school" do
      let(:organisation) { build_stubbed(:school) }

      it "returns 'School'" do
        expect(helper.organisation_label(organisation)).to eq("School")
      end
    end

    context "when the organisation is a trust" do
      let(:organisation) { build_stubbed(:trust) }

      it "returns 'Organisation'" do
        expect(helper.organisation_label(organisation)).to eq("Organisation")
      end
    end
  end

  describe "#organisation_type" do
    context "with catholic" do
      let(:organisation) { build_stubbed(:school, :catholic) }

      it "shows the religion" do
        expect(helper.organisation_type(organisation)).to eq("Independent school, Roman Catholic, ages 11 to 18")
      end
    end

    context "without religion" do
      let(:organisation) { build_stubbed(:school) }

      it "omits religion" do
        expect(helper.organisation_type(organisation)).to eq("Independent school, ages 11 to 18")
      end
    end
  end
end
