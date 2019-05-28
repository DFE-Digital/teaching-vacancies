require 'rails_helper'

RSpec.describe CopyVacancy do
  describe '#call' do
    it 'creates a new vacancy as draft' do
      original_vacancy = FactoryBot.build(:vacancy, job_title: 'Maths teacher')
      original_vacancy.save
      new_vacancy = original_vacancy.dup

      result = described_class.new(proposed_vacancy: new_vacancy)
                              .call

      expect(result).to be_kind_of(Vacancy)
      expect(Vacancy.count).to eq(2)
      expect(Vacancy.find(result.id).status).to eq('draft')
    end

    it 'does not change the original vacancy' do
      # Needed to compare a FactoryBot object fields for updated_at and created_at
      # and against the record it creates in Postgres.
      Timecop.freeze(Time.zone.local(2008, 9, 1, 12, 0, 0))

      original_vacancy = FactoryBot.create(:vacancy, job_title: 'Maths teacher')
      new_vacancy = original_vacancy.dup

      described_class.new(proposed_vacancy: new_vacancy)
                     .call

      expect(Vacancy.find(original_vacancy.id).attributes == original_vacancy.attributes)
        .to eq(true)

      Timecop.return
    end

    context 'when a new job_title is provided' do
      it 'creates a new vacancy with a new job title' do
        original_vacancy = FactoryBot.create(:vacancy, job_title: 'Maths teacher')
        new_vacancy = original_vacancy.dup
        new_vacancy.job_title = 'English teacher'

        result = described_class.new(proposed_vacancy: new_vacancy)
                                .call

        expect(Vacancy.find(result.id).job_title).to eq('English teacher')
      end
    end

    context 'when new dates are provided' do
      it 'creates a new vacancy with the new dates' do
        original_vacancy = FactoryBot.create(:vacancy, job_title: 'Maths teacher')
        new_vacancy = original_vacancy.dup
        new_vacancy.starts_on = 60.days.from_now
        new_vacancy.ends_on = 100.days.from_now
        new_vacancy.publish_on = 0.days.from_now
        new_vacancy.expires_on = 50.days.from_now

        result = described_class.new(proposed_vacancy: new_vacancy)
                                .call

        created_vacancy = Vacancy.find(result.id)
        expect(created_vacancy.starts_on).to eq(new_vacancy.starts_on)
        expect(created_vacancy.ends_on).to eq(new_vacancy.ends_on)
        expect(created_vacancy.publish_on).to eq(new_vacancy.publish_on)
        expect(created_vacancy.expires_on).to eq(new_vacancy.expires_on)
      end
    end
  end
end
