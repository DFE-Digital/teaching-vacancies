require "rails_helper"

RSpec.describe Search::VacancySearchSort do
  subject { described_class.for(key, keyword: keyword) }
  let(:key) { "" }
  let(:keyword) { "" }

  context "when no key parameter is specified" do
    context "and a keyword is specified" do
      let(:keyword) { "maths" }

      it { is_expected.to eq(Search::VacancySearchSort::RELEVANCE) }

      it "does not use any search replica" do
        expect(subject.algolia_replica).to be_nil
      end
    end

    context "and a keyword is NOT specified" do
      it { is_expected.to eq(Search::VacancySearchSort::PUBLISH_ON_DESC) }

      it "uses the default search replica" do
        expect(subject.algolia_replica).to eq("#{Indexable::INDEX_NAME}_publish_on_desc")
      end
    end
  end

  context "when an invalid sort strategy is specified" do
    let(:key) { "worst_listing" }

    it { is_expected.to eq(Search::VacancySearchSort::PUBLISH_ON_DESC) }

    it "uses the default search replica" do
      expect(subject.algolia_replica).to eq("#{Indexable::INDEX_NAME}_publish_on_desc")
    end
  end

  context "when a valid non-default sort strategy is specified" do
    let(:key) { "expires_at_desc" }

    it { is_expected.to eq(Search::VacancySearchSort::EXPIRES_AT_DESC) }

    it "uses the specified search replica" do
      expect(subject.algolia_replica).to eq("#{Indexable::INDEX_NAME}_expires_at_desc")
    end

    context "and a keyword is specified" do
      let(:keyword) { "maths teacher" }

      it { is_expected.to eq(Search::VacancySearchSort::EXPIRES_AT_DESC) }

      it "uses the specified search replica" do
        expect(subject.algolia_replica).to eq("#{Indexable::INDEX_NAME}_expires_at_desc")
      end
    end
  end
end
