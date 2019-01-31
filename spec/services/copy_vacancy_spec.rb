require 'rails_helper'

RSpec.describe CopyVacancy do
  describe '#call' do
    it 'creates a new vacancy as draft' do
      original_vacancy = FactoryBot.build(:vacancy, job_title: 'Maths teacher')
      original_vacancy.save
      new_vacancy = original_vacancy.dup

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
