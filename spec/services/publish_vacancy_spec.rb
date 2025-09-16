require "rails_helper"

RSpec.describe PublishVacancy do
  let(:organisation) { create(:school) }
  let(:user) { create(:publisher) }
  let(:vacancy) { create(:draft_vacancy, publisher: nil) }

  describe "#call" do
    it "updates the vacancy's status to published" do
      PublishVacancy.new(vacancy, user, organisation).call

      expect(vacancy.type).to eq("PublishedVacancy")
    end

    it "updates the id of the user who confirmed the publishing of a vacancy" do
      PublishVacancy.new(vacancy, user, organisation).call

      expect(Vacancy.find(vacancy.id).publisher_id).to eq(user.id)
    end

    it "updates the id of the organisation of the user who confirmed the publishing of a vacancy" do
      PublishVacancy.new(vacancy, user, organisation).call

      expect(Vacancy.find(vacancy.id).publisher_organisation_id).to eq(organisation.id)
    end
  end
end
