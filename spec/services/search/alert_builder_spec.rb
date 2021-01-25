require "rails_helper"

RSpec.describe Search::AlertBuilder do
  let(:subject) { described_class.new(subscription_hash) }

  let!(:expired_now) { Time.current }

  let(:keyword) { "maths teacher" }
  let(:location) { "SW1A 1AA" }
  let(:date_today) { Date.current.to_time }
  let(:location_point_coordinates) { Geocoder::DEFAULT_STUB_COORDINATES }
  let(:location_radius) { convert_miles_to_metres(10) }
  let(:location_polygon_boundaries) { nil }
  let(:search_replica) { nil }
  let(:max_subscription_results) { 500 }

  let(:expected_algolia_search_args) do
    {
      aroundLatLng: location_point_coordinates,
      aroundRadius: location_radius,
      insidePolygon: location_polygon_boundaries,
      filters: search_filter,
      replica: search_replica,
      hitsPerPage: max_subscription_results,
      typoTolerance: false,
    }.compact
  end

  before do
    travel_to(expired_now)
    allow_any_instance_of(Search::FiltersBuilder).to receive(:expired_now_filter).and_return(expired_now.to_time.to_i)
  end

  after(:all) do
    travel_back
  end

  context "subscription created before algolia" do
    let(:search_subject) { "maths" }
    let(:job_title) { "teacher" }
    let(:search_query) { "#{search_subject} #{job_title}" }
    let(:subscription_hash) do
      {
        location: location,
        subject: search_subject,
        job_title: job_title,
        working_patterns: %w[full_time part_time],
        newly_qualified_teacher: "true",
        phases: %w[secondary primary],
        from_date: date_today,
        to_date: date_today,
      }
    end

    context "#initialize" do
      context "#keyword" do
        it "adds subject and job_title to the keyword" do
          expect(subject.keyword).to eq(search_query)
        end
      end

      context "#build_subscription_filters" do
        it "adds date filter" do
          expect(subject.search_filters).to include(
            "(publication_date_timestamp >= #{date_today.to_i} AND publication_date_timestamp <= #{date_today.to_i})",
          )
        end

        it "adds working patterns filter" do
          expect(subject.search_filters).to include(
            "(working_patterns:'full_time' OR working_patterns:'part_time')",
          )
        end

        it "adds NQT filter" do
          expect(subject.search_filters).to include(
            "(job_roles:'nqt_suitable')",
          )
        end

        it "adds school phase filter" do
          expect(subject.search_filters).to include(
            "(education_phases:'secondary' OR education_phases:'primary')",
          )
        end
      end
    end

    context "#call" do
      let(:vacancies) { double("vacancies") }
      let(:search_filter) do
        "(publication_date_timestamp <= #{date_today.to_i} AND expires_at_timestamp > #{expired_now.to_time.to_i})"\
        " AND (publication_date_timestamp >= #{date_today.to_i} AND publication_date_timestamp <="\
        " #{date_today.to_i}) AND "\
        "(education_phases:'secondary' OR education_phases:'primary') AND "\
        "(working_patterns:'full_time' OR working_patterns:'part_time') AND "\
        "(job_roles:'nqt_suitable')"
      end

      before do
        mock_algolia_search(vacancies, 10, search_query, expected_algolia_search_args)
      end

      it "carries out alert search with correct criteria" do
        expect(subject.vacancies).to eq(vacancies)
      end
    end
  end

  context "subscription created after algolia" do
    let(:vacancies) { double("vacancies") }
    let(:subscription_hash) do
      {
        location: location,
        keyword: keyword,
        from_date: date_today,
        to_date: date_today,
      }
    end

    context "#call" do
      let(:search_filter) do
        "(publication_date_timestamp <= #{date_today.to_i} AND expires_at_timestamp > "\
        "#{expired_now.to_time.to_i}) AND (publication_date_timestamp >= "\
        "#{date_today.to_i} AND publication_date_timestamp <= #{date_today.to_i})"
      end

      before do
        mock_algolia_search(vacancies, 10, keyword, expected_algolia_search_args)
      end

      it "carries out alert search with correct criteria" do
        expect(subject.vacancies).to eq(vacancies)
      end
    end
  end
end
