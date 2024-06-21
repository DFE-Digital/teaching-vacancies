require "rails_helper"

RSpec.describe PublishVacancy do
  let(:organisation) { create(:school) }
  let(:user) { create(:publisher) }
  let(:vacancy) { create(:vacancy, :draft, publisher: nil) }

  describe "#call" do
    it "updates the vacancy's status to published" do
      described_class.new(vacancy, user, organisation).call

      expect(vacancy.status).to eq("published")
    end

    it "updates the id of the user who confirmed the publishing of a vacancy" do
      described_class.new(vacancy, user, organisation).call
      vacancy.reload

      expect(vacancy.publisher_id).to eq(user.id)
    end

    it "updates the id of the organisation of the user who confirmed the publishing of a vacancy" do
      described_class.new(vacancy, user, organisation).call
      vacancy.reload

      expect(vacancy.publisher_organisation_id).to eq(organisation.id)
    end
  end
end
