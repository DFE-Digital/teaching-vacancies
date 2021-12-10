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

  context "when an invalid sort strategy is specified" do
    let(:key) { "worst_listing" }

    it { is_expected.to eq(Search::VacancySearchSort::PUBLISH_ON_DESC) }
  end

  context "when a valid non-default sort strategy is specified" do
    let(:key) { "expires_at_desc" }

    it { is_expected.to eq(Search::VacancySearchSort::EXPIRES_AT_DESC) }

    context "and a keyword is specified" do
      let(:keyword) { "maths teacher" }

      it { is_expected.to eq(Search::VacancySearchSort::EXPIRES_AT_DESC) }
    end
  end
end
