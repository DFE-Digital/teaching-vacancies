require 'rails_helper'

RSpec.describe PublishVacancy do
  let(:organisation) { create(:school) }
  let(:user) { create(:user) }
  let(:vacancy) { create(:vacancy, :draft, publisher_user: nil) }

  describe '#call' do
    it "updates the vacancy's status to published" do
      PublishVacancy.new(vacancy, user, organisation).call

      expect(vacancy.status).to eq('published')
    end

    it 'updates the id of the user who confirmed the publishing of a vacancy' do
      PublishVacancy.new(vacancy, user, organisation).call
      vacancy.reload

      expect(vacancy.publisher_user_id).to eq(user.id)
    end

    it 'updates the id of the organisation of the user who confirmed the publishing of a vacancy' do
      PublishVacancy.new(vacancy, user, organisation).call
      vacancy.reload

      expect(vacancy.publisher_organisation_id).to eq(organisation.id)
    end
  end
end
