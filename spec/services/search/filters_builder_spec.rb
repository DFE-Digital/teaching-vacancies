require "rails_helper"

RSpec.describe Search::FiltersBuilder do
  subject { described_class.new(filters_hash) }

  let(:filters_hash) do
    {
      from_date:,
      to_date:,
      job_roles:,
      phases:,
      working_patterns:,
      subjects:,
      newly_qualified_teacher:,
    }
  end

  let(:from_date) { Date.current }
  let(:to_date) { Date.current }
  let(:job_roles) { %w[teacher send_responsible] }
  let(:phases) { %w[secondary primary] }
  let(:working_patterns) { %w[full_time part_time] }
  let(:subjects) { %w[Science Biology] }
  let(:newly_qualified_teacher) { nil }
  let(:published_today_filter) { Date.current.to_time.to_i }
  let(:expired_now_filter) { Time.current.to_time.to_i }

  describe "#build_date_filters" do
    context "when no dates are supplied" do
      let(:from_date) { nil }
      let(:to_date) { nil }

      it "builds the correct date filter" do
        expect(subject.send(:build_date_filters)).to be_blank
      end
    end

    context "when only from date is supplied" do
      let(:to_date) { nil }

      it "builds the correct date filter" do
        expect(subject.send(:build_date_filters)).to eq("publication_date_timestamp >= #{from_date.to_time.to_i}")
      end
    end

    context "when only to date is supplied" do
      let(:from_date) { nil }

      it "builds the correct date filter" do
        expect(subject.send(:build_date_filters)).to eq("publication_date_timestamp <= #{to_date.to_time.to_i}")
      end
    end

    context "when both dates are supplied" do
      it "builds the correct date filter" do
        expect(subject.send(:build_date_filters)).to eq(
          "publication_date_timestamp >= #{from_date.to_time.to_i} AND " \
          "publication_date_timestamp <= #{to_date.to_time.to_i}",
        )
      end
    end
  end

  describe "#filter_query" do
    context "when a filter is not present in the hash" do
      let(:phases) { nil }

      it "omits the filter from the query" do
        expect(subject.filter_query).not_to match(/phases/)
      end
    end

    context "when a filter contains enum values that no longer exist" do
      let(:working_patterns) { ["full_time", nil] }

      it "only filters the valid working pattern" do
        expect(subject.filter_query).to include("(working_patterns:'full_time')")
      end
    end

    context "when subscription was created before algolia" do
      let(:newly_qualified_teacher) { "true" }

      it "filters ECT jobs" do
        expect(subject.filter_query).to match(/job_roles:'ect_suitable'/)
      end
    end

    context "when filters are present" do
      let(:expired_now) { Time.current }

      before do
        travel_to(expired_now)
        allow_any_instance_of(Search::FiltersBuilder)
          .to receive(:expired_now_filter)
          .and_return(expired_now.to_time.to_i)
      end

      after { travel_back }

      it "builds the correct query" do
        expect(subject.filter_query).to eq(
          "(publication_date_timestamp <= #{published_today_filter} AND"\
          " expires_at_timestamp > #{expired_now_filter}) AND "\
          "(publication_date_timestamp >= #{from_date.to_time.to_i} AND" \
          " publication_date_timestamp <= #{to_date.to_time.to_i}) AND " \
          "(job_roles:'teacher' OR job_roles:'send_responsible') AND " \
          "(education_phases:'secondary' OR education_phases:'primary') AND " \
          "(working_patterns:'full_time' OR working_patterns:'part_time') AND " \
          "(subjects:'Science' OR subjects:'Biology')",
        )
      end
    end
  end
end
