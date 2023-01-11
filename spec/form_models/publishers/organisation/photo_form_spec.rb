require "rails_helper"

RSpec.describe Publishers::Organisation::PhotoForm, type: :model do
  let(:photo_form) { described_class.new(photo: photo_file) }
  let(:attribute) { :photo }
  let(:photo_file) { File.open(Rails.root.join("spec/fixtures/files/blank_image.png")) }

  it "runs the validations in the form file validator" do
    expect_any_instance_of(FormFileValidator).to receive(:validate_each).with(photo_form, attribute, photo_file)

    photo_form.valid?
  end
end
