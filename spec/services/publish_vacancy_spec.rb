require "rails_helper"

RSpec.describe PublishVacancy do
  let(:organisation) { create(:school) }
  let(:user) { create(:publisher) }
  let(:vacancy) { create(:draft_vacancy, publisher: nil) }

  describe "#call" do
    let(:published) { PublishVacancy.call(vacancy, user, organisation) }

    it "updates the vacancy's status to published" do
      expect(published.status).to eq("published")
    end

    it "updates the id of the user who confirmed the publishing of a vacancy" do
      expect(published.publisher_id).to eq(user.id)
    end

    it "updates the id of the organisation of the user who confirmed the publishing of a vacancy" do
      expect(published.publisher_organisation_id).to eq(organisation.id)
    end
  end
end
