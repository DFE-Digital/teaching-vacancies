require "rails_helper"

RSpec.describe ImageManipulator do
  subject { described_class.new(image_file_path: blank_image_file_path) }

  describe "#alter_dimensions_and_preserve_aspect_ratio" do
    let(:blank_image_file_path) { File.new(Rails.root.join("spec/fixtures/files/blank_landscape_image.png")).path }
    let(:desired_image_dimensions) { %w[100 100] }

    it "creates a new MiniMagick::Image object using the image file's path" do
      expect(MiniMagick::Image).to receive(:open).with(blank_image_file_path).and_call_original

      subject.alter_dimensions_and_preserve_aspect_ratio(*desired_image_dimensions)
    end

    it "resizes the image using the dimensions provided" do
      # MiniMagick::Image does not implement #resize. Because of this, MiniMagick::Image's #method_missing method
      # is called. This in turn uses MiniMagick::Tool::Mogrify to tell ImageMagick to use the -resize option with the arguments
      # provided.

      expect_any_instance_of(MiniMagick::Tool::MogrifyRestricted).to receive(:send).with(:resize, desired_image_dimensions.join("x"))

      subject.alter_dimensions_and_preserve_aspect_ratio(*desired_image_dimensions)
    end

    describe "preserving the aspect ratio" do
      let(:pre_processing_image_size) { FastImage.size(Rails.root.join("spec/fixtures/files/blank_landscape_image.png")) }
      let(:pre_processing_aspect_ratio) { Rational(*pre_processing_image_size).round(1) }
      let(:logo) { subject.alter_dimensions_and_preserve_aspect_ratio(*desired_image_dimensions) }
      let(:post_processing_aspect_ratio) { Rational(*logo.dimensions).round(1) }

      it "preserves the aspect ratio" do
        expect(post_processing_aspect_ratio).to eq(pre_processing_aspect_ratio)
      end

      context "when the image's width is larger than the desired width" do
        it "alters the image's width to the desired size" do
          expect(logo.width).to eq(desired_image_dimensions.first.to_i)
        end

        it "changes the height of the image to maintain the aspect ratio" do
          expect(logo.height).not_to eq(pre_processing_image_size.last)
        end
      end

      context "when the image's height is larger than the desired height" do
        let(:blank_image_file_path) { File.new(Rails.root.join("spec/fixtures/files/blank_portrait_image.png")).path }

        it "alters the image's height to the desired size" do
          expect(logo.height).to eq(desired_image_dimensions.last.to_i)
        end

        it "changes the height of the image to maintain the aspect ratio" do
          expect(logo.width).not_to eq(pre_processing_image_size.first)
        end
      end
    end
  end
end
