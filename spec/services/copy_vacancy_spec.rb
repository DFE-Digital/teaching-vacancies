require 'rails_helper'

RSpec.describe CopyVacancy do
  describe '#call' do
    it 'creates a new vacancy as draft' do
      vacancy = create(:vacancy, job_title: 'Maths teacher')

      result = described_class.new(vacancy).call

      expect(result).to be_kind_of(Vacancy)
      expect(Vacancy.count).to eq(2)
      expect(Vacancy.find(result.id).status).to eq('draft')
    end

    it 'does not change the original vacancy' do
      # Needed to compare a FactoryBot object fields for updated_at and created_at
      # and against the record it creates in Postgres.
      Timecop.freeze(Time.zone.local(2008, 9, 1, 12, 0, 0))

      vacancy = create(:vacancy, job_title: 'Maths teacher')

      described_class.new(vacancy).call

      expect(Vacancy.find(vacancy.id).attributes == vacancy.attributes)
        .to eq(true)

      Timecop.return
    end
  end
end
