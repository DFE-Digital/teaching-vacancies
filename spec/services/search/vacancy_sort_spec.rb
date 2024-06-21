require "rails_helper"

RSpec.describe Search::VacancySort do
  subject { described_class.new(keyword: keyword).update(sort_by: sort_by) }

  let(:sort_by) { "" }
  let(:keyword) { "" }

  shared_examples "sorts by publish_on" do
    it "sorts by publish_on" do
      expect(subject.sort_by).to eq("publish_on")
    end

    it "has order 'desc'" do
      expect(subject.order).to eq("desc")
    end
  end

  shared_examples "sorts by distance" do
    it "sorts by publish_on" do
      expect(subject.sort_by).to eq("distance")
    end

    it "has order 'desc'" do
      expect(subject.order).to eq("asc")
    end
  end

  describe "#default_option" do
    context "when a location is passed" do
      subject { described_class.new(keyword: keyword, location: "E14 9PG").update(sort_by: sort_by) }

      context "when no sort_by parameter is specified" do
        context "and a keyword is specified" do
          let(:keyword) { "maths" }

          it_behaves_like "sorts by distance"
        end

        context "and a keyword is NOT specified" do
          it_behaves_like "sorts by distance"
        end
      end

      context "when an invalid sort strategy is specified" do
        let(:sort_by) { "worst_listing" }
        let(:keyword) { "maths" }

        it_behaves_like "sorts by distance"
      end
    end

    context "when no location is passed" do
      context "when no sort_by parameter is specified" do
        context "and a keyword is specified" do
          let(:keyword) { "maths" }

          it_behaves_like "sorts by publish_on"
        end

        context "and a keyword is NOT specified" do
          it_behaves_like "sorts by publish_on"
        end
      end

      context "when an invalid sort strategy is specified" do
        let(:sort_by) { "worst_listing" }
        let(:keyword) { "maths" }

        it_behaves_like "sorts by publish_on"
      end
    end
  end

  describe "#options" do
    context "when the sort option 'relevance' is selected and there is no keyword" do
      let(:sort_by) { "relevance" }

      it_behaves_like "sorts by publish_on"

      it "does not include 'relevance' in the sorting options" do
        expect(subject.options.map(&:sort_by)).not_to include("relevance")
      end
    end

    context "when the sort option `expires_at` is selected" do
      let(:sort_by) { "expires_at" }

      it "sorts by publish_on" do
        expect(subject.sort_by).to eq("expires_at")
      end

      it "has order 'asc'" do
        expect(subject.order).to eq("asc")
      end
    end
  end

  context "when a valid non-default sort strategy is specified" do
    let(:sort_by) { "publish_on" }

    it_behaves_like "sorts by publish_on"

    context "and a keyword is specified" do
      let(:keyword) { "maths teacher" }

      it_behaves_like "sorts by publish_on"
    end
  end

  describe "#by_db_column?" do
    context "when sorting by relevance" do
      let(:sort_by) { "relevance" }
      let(:keyword) { "test" }

      it { is_expected.to be_by_db_column }
    end

    context "when sorting by publish_on" do
      let(:sort_by) { "publish_on" }

      it { is_expected.to be_by_db_column }
    end

    context "when sorting by publish_on" do
      let(:sort_by) { "publish_on_non_default" }

      it { is_expected.to be_by_db_column }
    end
  end
end
