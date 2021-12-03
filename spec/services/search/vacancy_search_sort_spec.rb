require "rails_helper"

RSpec.describe Search::VacancySearchSort do
  subject { described_class.for(key, keyword: keyword) }
  let(:key) { "" }
  let(:keyword) { "" }

  context "when no key parameter is specified" do
    context "and a keyword is specified" do
      let(:keyword) { "maths" }

      it { is_expected.to eq(Search::VacancySearchSort::RELEVANCE) }
    end

    context "and a keyword is NOT specified" do
      it { is_expected.to eq(Search::VacancySearchSort::PUBLISH_ON_DESC) }
    end
  end

  context "when the sort option 'relevance' is selected and there is no keyword" do
    let(:key) { "relevance" }

    it { is_expected.to eq(Search::VacancySearchSort::PUBLISH_ON_DESC) }

    it "does not include 'relevance' in the sorting options" do
      expect(Search::VacancySearchSort.sorting_options(keyword: keyword)).not_to include(Search::VacancySearchSort::RELEVANCE)
    end
  end

  context "when an invalid sort strategy is specified" do
    let(:key) { "worst_listing" }

    it { is_expected.to eq(Search::VacancySearchSort::PUBLISH_ON_DESC) }
  end

  context "when a valid sort strategy is specified" do
    let(:key) { "publish_on_desc" }

    it { is_expected.to eq(Search::VacancySearchSort::PUBLISH_ON_DESC) }

    context "and a keyword is specified" do
      let(:keyword) { "maths teacher" }

      it { is_expected.to eq(Search::VacancySearchSort::PUBLISH_ON_DESC) }
    end
  end
end
