require 'rails_helper'

RSpec.describe PublishVacancy do
  let(:user) { create(:user) }
  let(:vacancy) { create(:vacancy, :draft, publisher_user: nil) }

  describe '#call' do
    it "updates the vacancy's status to published" do
      PublishVacancy.new(vacancy, user).call

      expect(vacancy.status).to eq('published')
    end

    it 'updates the id of the user who confirmed the publishing of a vacancy' do
      PublishVacancy.new(vacancy, user).call
      vacancy.reload

      expect(vacancy.publisher_user_id).to eq(user.id)
    end
  end
end
