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

    context 'not all fields are copied' do
      let(:vacancy) do
        create(:vacancy,
               job_title: 'Maths teacher',
               slug: 'maths-teacher',
               weekly_pageviews: 4,
               total_pageviews: 4,
               weekly_pageviews_updated_at: Time.zone.today - 5.days,
               total_pageviews_updated_at: Time.zone.today - 5.days,
               total_get_more_info_clicks: 6,
               total_get_more_info_clicks_updated_at: Time.zone.today - 5.days)
      end
      let(:result) { described_class.new(vacancy).call }

      it 'should not copy the slug of a vacancy' do
        expect(Vacancy.find(result.id).slug).to_not eq('maths-teacher')
      end

      it 'should not copy the weekly page views of a vacancy' do
        expect(Vacancy.find(result.id).weekly_pageviews).to eq(0)
      end

      it 'should not copy the weekly page views update time of a vacancy' do
        Timecop.freeze(Time.zone.today - 5.days) do
          expect(Vacancy.find(result.id).weekly_pageviews_updated_at).to eq(Time.zone.now)
        end
      end

      it 'should not copy the weekly page views of a vacancy' do
        expect(Vacancy.find(result.id).total_pageviews).to eq(0)
      end

      it 'should not copy the weekly page views update time of a vacancy' do
        Timecop.freeze(Time.zone.today - 5.days) do
          expect(Vacancy.find(result.id).total_pageviews_updated_at).to eq(Time.zone.now)
        end
      end

      it 'should not copy the weekly page views of a vacancy' do
        expect(Vacancy.find(result.id).total_get_more_info_clicks).to eq(0)
      end

      it 'should not copy the weekly page views update time of a vacancy' do
        Timecop.freeze(Time.zone.today - 5.days) do
          expect(Vacancy.find(result.id).total_get_more_info_clicks_updated_at).to eq(Time.zone.now)
        end
      end
    end
  end
end
