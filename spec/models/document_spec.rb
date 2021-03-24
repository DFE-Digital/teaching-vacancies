require "rails_helper"

RSpec.describe Document do
  it { is_expected.to belong_to(:vacancy) }

  describe "validations" do
    context "a new record" do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_presence_of(:size) }
      it { is_expected.to validate_presence_of(:content_type) }
      it { is_expected.to validate_presence_of(:download_url) }
      it { is_expected.to validate_presence_of(:google_drive_id) }
    end
  end
end
