require "rails_helper"

RSpec.describe "Updating an organisation logo" do
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:organisation) { build(:school) }
  let(:uploaded_image) { fixture_file_upload("blank_image.png", "image/png") }
  let(:dimensions) { %w[100 100] }
  let(:params) do
    {
      publishers_organisation_logo_form: {
        logo: uploaded_image,
      },
    }
  end

  before do
    sign_in(publisher, scope: :publisher)
    allow_any_instance_of(ApplicationController).to receive(:current_organisation).and_return(organisation)
    allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(double(safe?: true))
  end

  describe "PATCH #update" do
    subject { patch publishers_organisation_logo_path(organisation), params: params }

    it "normalises the logo before attaching it to the organisation" do
      expect_any_instance_of(ImageManipulator).to receive(:alter_dimensions_and_preserve_aspect_ratio).with(*dimensions).and_call_original

      subject
    end
  end
end
