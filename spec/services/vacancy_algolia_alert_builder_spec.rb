require 'rails_helper'

RSpec.describe VacancyAlgoliaAlertBuilder do
  subject { described_class.new(subscription_hash) }

  let(:keyword) { 'maths teacher' }
  let(:location) { 'SW1A 1AA' }
  let(:default_radius) { 10 }
  let(:date_today) { Time.zone.today.to_datetime }
  let(:location_coordinates) { Geocoder::DEFAULT_STUB_COORDINATES }
  let(:location_radius) { subject.convert_radius_in_miles_to_metres(default_radius) }
  let(:search_replica) { nil }
  let(:max_subscription_results) { 500 }

  let(:algolia_search_query) { search_query }
  let(:algolia_search_args) do
    {
      aroundLatLng: location_coordinates,
      aroundRadius: location_radius,
      replica: search_replica,
      hitsPerPage: max_subscription_results,
      filters: search_filter
    }
  end

  context 'pre Algolia subscriptions' do
    let(:search_subject) { 'maths' }
    let(:job_title) { 'teacher' }
    let(:search_query) { "#{search_subject} #{job_title}" }
    let(:subscription_hash) do
      {
        location: location,
        subject: search_subject,
        job_title: job_title,
        working_patterns: ['full_time', 'part_time'],
        newly_qualified_teacher: true,
        phases: ['secondary', 'primary'],
        from_date: date_today,
        to_date: date_today
      }
    end

    context '#initialize' do
      context '#keyword' do
        it 'adds subject and job_title to the keyword' do
          expect(subject.search_query).to eql(search_query)
        end
      end

      context '#build_subscription_filters' do
        it 'adds date filter' do
          expect(subject.filter_array).to include(
            "(publication_date_timestamp >= #{date_today.to_i} AND publication_date_timestamp <= #{date_today.to_i})"
          )
        end

        it 'adds working patterns filter' do
          expect(subject.filter_array).to include(
            '(working_pattern:full_time OR working_pattern:part_time)'
          )
        end

        it 'adds NQT filter' do
          expect(subject.filter_array).to include(
            "(job_roles:#{I18n.t('jobs.job_role_options.nqt_suitable')})"
          )
        end

        it 'adds school phase filter' do
          expect(subject.filter_array).to include(
            '(school.phase:secondary OR school.phase:primary)'
          )
        end
      end
    end

    context '#call' do
      let(:search_filter) do
        "(publication_date_timestamp <= #{date_today.to_i} AND expires_at_timestamp > #{date_today.to_i}) AND "\
        "(publication_date_timestamp >= #{date_today.to_i} AND publication_date_timestamp <= #{date_today.to_i}) AND "\
        '(working_pattern:full_time OR working_pattern:part_time) AND '\
        "(job_roles:#{I18n.t('jobs.job_role_options.nqt_suitable')}) AND "\
        '(school.phase:secondary OR school.phase:primary)'
      end

      before do
        mock_algolia_search('vacancies', algolia_search_query, algolia_search_args)
      end

      it 'carries out alert search with correct criteria' do
        subject.call
        expect(subject.vacancies).to eql('vacancies')
      end
    end
  end

  context 'post Algolia subscriptions' do
    let(:search_query) { keyword }
    let(:subscription_hash) do
      {
        location: location,
        keyword: keyword,
        from_date: date_today,
        to_date: date_today
      }
    end

    context '#call' do
      let(:search_filter) do
        "(publication_date_timestamp <= #{date_today.to_i} AND expires_at_timestamp > #{date_today.to_i}) AND "\
        "(publication_date_timestamp >= #{date_today.to_i} AND publication_date_timestamp <= #{date_today.to_i})"
      end

      before do
        mock_algolia_search('vacancies', algolia_search_query, algolia_search_args)
      end

      it 'carries out alert search with correct criteria' do
        subject.call
        expect(subject.vacancies).to eql('vacancies')
      end
    end
  end
end
