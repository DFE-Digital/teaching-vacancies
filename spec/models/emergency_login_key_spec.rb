require "rails_helper"

RSpec.describe EmergencyLoginKey, type: :model do
  it { should belong_to(:publisher) }

  describe "validations" do
    context "a new key" do
      it { should validate_presence_of(:not_valid_after) }
    end
  end
end
