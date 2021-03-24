require "rails_helper"

RSpec.describe EmergencyLoginKey do
  it { is_expected.to belong_to(:publisher) }

  describe "validations" do
    context "a new key" do
      it { is_expected.to validate_presence_of(:not_valid_after) }
    end
  end
end
