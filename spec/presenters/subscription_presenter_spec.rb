require "rails_helper"

RSpec.describe SubscriptionPresenter do
  let(:presenter) { described_class.new(subscription) }
  let(:subscription) { Subscription.new(search_criteria:) }
  let(:search_criteria) { { keyword: "english" } }

  describe "#formatted_search_criteria" do
    context "when the location is not a LocationPolygon" do
      let(:search_criteria) { { location: "EC2 9AN", radius: "10" } }

      it "formats and returns the search criteria" do
        expect(presenter.filtered_search_criteria["location"]).to eq("Within 10 miles of EC2 9AN")
      end
    end

    context "when the location is a LocationPolygon" do
      context "when the radius is present" do
        let(:search_criteria) { { location: "Barnet", radius: "10" } }

        it "formats and returns the search criteria" do
          expect(presenter.filtered_search_criteria["location"]).to eq("Within 10 miles of Barnet")
        end

        context "when the radius is 0" do
          let(:search_criteria) { { location: "Barnet", radius: "0" } }

          it "formats and returns the search criteria" do
            expect(presenter.filtered_search_criteria["location"]).to eq("In Barnet")
          end
        end
      end

      context "when the radius does not exist" do
        let(:search_criteria) { { location: "Barnet" } }

        it "formats and returns the search criteria" do
          expect(presenter.filtered_search_criteria["location"]).to eq("In Barnet")
        end
      end
    end

    context "without location information" do
      let(:search_criteria) { { radius: "10" } }

      it "does not return location or radius information" do
        expect(presenter.filtered_search_criteria.key?("location")).to eq(false)
        expect(presenter.filtered_search_criteria.key?("radius")).to eq(false)
      end
    end

    context "with the working_patterns filter" do
      let(:search_criteria) { { working_patterns: %w[part_time] } }

      it "formats and returns the working pattern" do
        expect(presenter.filtered_search_criteria["working_patterns"]).to eq("Part time")
      end
    end

    context "with the phases filter" do
      let(:search_criteria) { { phases: %w[secondary 16-19] } }

      it "formats and returns the phases" do
        expect(presenter.filtered_search_criteria["education_phases"]).to eq("Secondary, 16-19")
      end
    end

    context "with the ECT filter" do
      let(:search_criteria) { { newly_qualified_teacher: "true" } }

      it "formats and returns the working pattern" do
        expect(presenter.filtered_search_criteria[""]).to eq("Suitable for ECTs")
      end
    end

    context "with unsorted filters" do
      let(:search_criteria) do
        {
          phases: %w[secondary 16-19],
          radius: "10",
          job_title: "leader",
          newly_qualified_teacher: "true",
          location: "EC2 9AN",
          working_patterns: %w[part_time],
          subject: "maths",
        }
      end

      it "returns the filters in sort order" do
        expect(presenter.filtered_search_criteria).to eq(
          "location" => "Within 10 miles of EC2 9AN",
          "subject" => "maths",
          "job_title" => "leader",
          "working_patterns" => "Part time",
          "education_phases" => "Secondary, 16-19",
          "" => "Suitable for ECTs",
        )
      end
    end

    context "with unknown filters" do
      let(:search_criteria) do
        {
          radius: "10",
          something: "test",
          job_title: "leader",
          newly_qualified_teacher: "true",
          something_else: "testing",
          location: "EC2 9AN",
          subject: "maths",
        }
      end

      it "returns the unknown filters last" do
        expect(presenter.filtered_search_criteria).to eq(
          "location" => "Within 10 miles of EC2 9AN",
          "subject" => "maths",
          "job_title" => "leader",
          "" => "Suitable for ECTs",
          "something" => "test",
          "something_else" => "testing",
        )
      end
    end
  end

  describe "#full_search_criteria" do
    let(:full_search_criteria) { presenter.send(:full_search_criteria) }

    it "adds all possible search criteria to subscription criteria" do
      expect(full_search_criteria.count).to eq(described_class::SEARCH_CRITERIA_SORT_ORDER.count)
      expect(full_search_criteria.keys).to match_array(described_class::SEARCH_CRITERIA_SORT_ORDER)
      expect(full_search_criteria[:keyword]).to eq(search_criteria[:keyword])
    end
  end

  describe "#search_criteria_field" do
    it "does not return the radius field" do
      expect(presenter.send(:search_criteria_field, "radius", "some radius")).to eq(nil)
    end

    it "does not return the sort_by field" do
      expect(presenter.send(:search_criteria_field, "sort_by", "search_replica")).to eq(nil)
    end

    it "returns a field:value hash" do
      expect(presenter.send(:search_criteria_field, "random_field", "value")).to eq({ random_field: "value" })
    end
  end
end
