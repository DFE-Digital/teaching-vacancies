require "rails_helper"

RSpec.describe Publishers::Organisation::LogoForm, type: :model do
  let(:logo_form) { described_class.new(logo: logo_file) }
  let(:attribute) { :logo }
  let(:logo_file) { File.open(Rails.root.join("spec/fixtures/files/blank_image.png")) }

  it "runs the validations in the form file validator" do
    expect_any_instance_of(FormFileValidator).to receive(:validate_each).with(logo_form, attribute, logo_file)

    logo_form.valid?
  end
end
