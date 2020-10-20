require 'rails_helper'

RSpec.describe VacancyFacets do
  let(:store) { MockRedis.new }
  let(:subject) { described_class.new(store: store) }

  describe '#get' do
    context 'when the field is set in redis' do
      let(:field) { :job_roles }
      let(:facet) { { teacher: 5 }.to_json }

      before { store.set(field, facet) }

      it 'retrieves the relevant facet' do
        expect(subject.get(field)).to eq({ 'teacher' => 5 })
      end
    end

    context 'when the field is not been set in redis' do
      let(:field) { :not_set }

      it 'returns an empty hash' do
        expect(subject.get(field)).to eq({})
      end
    end
  end

  describe '#refresh' do
    let(:job_role_count) { Vacancy::JOB_ROLE_OPTIONS.count }
    let(:subject_count) { SUBJECT_OPTIONS.count }
    let(:city_count) { CITIES.count }
    let(:county_count) { COUNTIES.count }

    it 'calls Search::VacancySearchBuilder' do
      JOB_ROLES_SUBJECTS_CITIES_AND_COUNTIES = job_role_count + subject_count + city_count + county_count

      search = instance_double('Search::VacancySearchBuilder', stats: [0, 0, 5])
      expect(search).to receive(:call).and_return(search).exactly(JOB_ROLES_SUBJECTS_CITIES_AND_COUNTIES).times
      expect(Search::VacancySearchBuilder).to receive(:new).and_return(search).exactly(JOB_ROLES_SUBJECTS_CITIES_AND_COUNTIES).times
      subject.refresh
    end
  end
end
