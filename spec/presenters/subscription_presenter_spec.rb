require "rails_helper"

RSpec.describe SubscriptionPresenter do
  let(:presenter) { described_class.new(subscription) }
  let(:subscription) { Subscription.new(search_criteria: search_criteria) }
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
      let(:search_criteria) { { phases: %w[secondary middle] } }

      it "formats and returns the phases" do
        expect(presenter.filtered_search_criteria["education_phases"]).to eq("Secondary school, Middle school")
      end
    end

    context "when the job alert has been created from an organisation landing page" do
      let(:search_criteria) { { organisation_slug: organisation.slug } }

      context "when the organisation is a school" do
        let(:organisation) { create(:school) }

        it "formats and returns the organisation type as the key and the organisation name as the value" do
          expect(presenter.filtered_search_criteria["School"]).to eq(organisation.name)
        end
      end

      context "when the organisation is a trust" do
        let(:organisation) { create(:trust) }

        it "formats and returns the organisation type as the key and the organisation name as the value" do
          expect(presenter.filtered_search_criteria["Trust"]).to eq(organisation.name)
        end
      end

      context "when the organisation is a local authority" do
        let(:organisation) { create(:local_authority) }

        it "formats and returns the organisation type as the key and the organisation name as the value" do
          expect(presenter.filtered_search_criteria["Local Authority"]).to eq(organisation.name)
        end
      end
    end

    context "when search criteria are in a different order to the presentable order" do
      let(:organisation) { create(:school) }
      let(:search_criteria) do
        {
          phases: %w[secondary sixth_form_or_college],
          organisation_slug: organisation.slug,
          radius: "10",
          job_roles: %w[leadership middle_leader],
          location: "EC2 9AN",
          working_patterns: %w[part_time],
          ect_statuses: %w[ect_suitable],
          subjects: %w[maths english science],
          keyword: "foobar",
        }
      end

      it "returns the filters in the presentable order" do
        expect(presenter.filtered_search_criteria.keys).to eq([
          organisation_type_basic(organisation).titleize,
          "keyword",
          "location",
          "job_role",
          "suitable_for_early_career_teachers",
          "subjects",
          "education_phases",
          "working_patterns",
        ])
      end
    end

    context "with unknown filters" do
      let(:organisation) { create(:school) }
      let(:search_criteria) do
        {
          radius: "10",
          something: "test",
          something_else: "testing",
          phases: %w[secondary sixth_form_or_college],
          organisation_slug: organisation.slug,
          job_roles: %w[leadership middle_leader],
          location: "EC2 9AN",
          working_patterns: %w[part_time],
          subjects: %w[maths english science],
          keyword: "foobar",
        }
      end

      it "returns the unknown filters last" do
        expect(presenter.filtered_search_criteria.keys).to eq([
          organisation_type_basic(organisation).titleize,
          "keyword",
          "location",
          "job_role",
          "subjects",
          "education_phases",
          "working_patterns",
          "something",
          "something_else",
        ])
      end
    end
  end

  describe "#search_criteria_field" do
    it "returns a field:value hash" do
      expect(presenter.send(:search_criteria_field, "random_field", "value")).to eq({ random_field: "value" })
    end
  end
end
