require 'rails_helper'

RSpec.describe CopyVacancy do
  describe '#update_fields' do
    context 'a published vacancy with a publish_on date in the past' do
      it 'updates the vacancy\'s publish_on field to enable it to be published' do
        vacancy = FactoryBot.build(:vacancy, :past_publish)
        vacancy_copy = CopyVacancy.new(vacancy: vacancy).copy

        expect(vacancy_copy.publish_on).to eq(Time.zone.today)
      end
    end

    context 'a published vacancy with a publish_on date in the future' do
      it 'does not update the vacancy\'s publish_on field' do
        vacancy = FactoryBot.build(:vacancy, :future_publish)
        vacancy_copy = CopyVacancy.new(vacancy: vacancy).copy

        expect(vacancy_copy.publish_on).to eq(vacancy.publish_on)
      end
    end

    it 'sets the copied vacancy\'s status to draft' do
      vacancy = FactoryBot.build(:vacancy, :published)
      vacancy_copy = CopyVacancy.new(vacancy: vacancy).copy

      expect(vacancy_copy.status).to eq('draft')
    end
  end
end
