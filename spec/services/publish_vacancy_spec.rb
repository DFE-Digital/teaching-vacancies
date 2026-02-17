require "rails_helper"

RSpec.describe PublishVacancy do
  let(:organisation) { create(:school) }
  let(:user) { create(:publisher) }
  let(:vacancy) { create(:draft_vacancy, publisher: nil, searchable_content: nil) }
  let(:published_vacancy) { Vacancy.find(vacancy.id) }

  describe "#call" do
    before do
      PublishVacancy.new(vacancy, user, organisation).call
    end

    it "updates the vacancy's status to published" do
      expect(vacancy.type).to eq("PublishedVacancy")
    end

    it "updates the id of the user who confirmed the publishing of a vacancy" do
      expect(published_vacancy.publisher_id).to eq(user.id)
    end

    it "updates the id of the organisation of the user who confirmed the publishing of a vacancy" do
      expect(published_vacancy.publisher_organisation_id).to eq(organisation.id)
    end

    it "updates the searchable content" do
      expect(published_vacancy.searchable_content).not_to be_nil
    end
  end
end
