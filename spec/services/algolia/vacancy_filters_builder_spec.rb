require 'rails_helper'

RSpec.describe Algolia::VacancyFiltersBuilder do
  subject { described_class.new(filters_hash) }

  let(:filters_hash) do
    {
      from_date: from_date,
      to_date: to_date,
      job_roles: job_roles,
      phases: phases,
      working_patterns: working_patterns,
      newly_qualified_teacher: newly_qualified_teacher
    }
  end

  let(:from_date) { Time.zone.today }
  let(:to_date) { Time.zone.today }
  let(:job_roles) { ['teacher', 'sen_specialist'] }
  let(:phases) { ['secondary', 'primary'] }
  let(:working_patterns) { ['full_time', 'part_time'] }
  let(:newly_qualified_teacher) { nil }
  let(:published_today_filter) { Time.zone.today.to_datetime.to_i }
  let(:expired_now_filter) { Time.zone.now.to_datetime.to_i }

  describe '#build_date_filters' do
    context 'when no dates are supplied' do
      let(:from_date) { nil }
      let(:to_date) { nil }

      it 'builds the correct date filter' do
        expect(subject.send(:build_date_filters)).to be_blank
      end
    end

    context 'when only from date is supplied' do
      let(:to_date) { nil }

      it 'builds the correct date filter' do
        expect(subject.send(:build_date_filters)).to eql("publication_date_timestamp >= #{from_date.to_datetime.to_i}")
      end
    end

    context 'when only to date is supplied' do
      let(:from_date) { nil }

      it 'builds the correct date filter' do
        expect(subject.send(:build_date_filters)).to eql("publication_date_timestamp <= #{to_date.to_datetime.to_i}")
      end
    end

    context 'when both dates are supplied' do
      it 'builds the correct date filter' do
        expect(subject.send(:build_date_filters)).to eql(
          "publication_date_timestamp >= #{from_date.to_datetime.to_i} AND " \
          "publication_date_timestamp <= #{to_date.to_datetime.to_i}"
        )
      end
    end
  end

  describe '#filter_query' do
    context 'when a filter is not present in the hash' do
      let(:phases) { nil }

      it 'omits the filter from the query' do
        expect(subject.filter_query).not_to match(/phases/)
      end
    end

    context 'when subscription was created before algolia' do
      let(:newly_qualified_teacher) { 'true' }

      it 'filters NQT jobs' do
        expect(subject.filter_query).to match(/job_roles:nqt_suitable/)
      end
    end

    context 'when filters are present' do
      let(:expired_now) { Time.zone.now }

      before do
        travel_to(expired_now)
        allow_any_instance_of(Algolia::VacancyFiltersBuilder)
          .to receive(:expired_now_filter)
          .and_return(expired_now.to_datetime.to_i)
      end

      after { travel_back }

      it 'builds the correct query' do
        expect(subject.filter_query).to eql(
          '(listing_status:published AND'\
          " publication_date_timestamp <= #{published_today_filter} AND"\
          " expires_at_timestamp > #{expired_now_filter}) AND "\
          "(publication_date_timestamp >= #{from_date.to_datetime.to_i} AND" \
          " publication_date_timestamp <= #{to_date.to_datetime.to_i}) AND " \
          '(job_roles:teacher OR job_roles:sen_specialist) AND ' \
          '(school.phase:secondary OR school.phase:primary) AND ' \
          '(working_patterns:full_time OR working_patterns:part_time)'
        )
      end
    end
  end
end
