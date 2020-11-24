require "rails_helper"

RSpec.describe Search::ReplicaBuilder do
  let(:subject) { described_class.new(job_sort, keyword) }

  describe "#search_replica" do
    let(:keyword) { "" }
    let(:job_sort) { "" }

    context "when no job_sort parameter is specified" do
      context "and a keyword is specified" do
        let(:keyword) { "maths" }
        it "does not use any search replica" do
          expect(subject.search_replica).to be_nil
        end
      end

      context "and a keyword is NOT specified" do
        it "uses the default search replica" do
          expect(subject.search_replica).to eql("#{Indexable::INDEX_NAME}_publish_on_desc")
        end
      end
    end

    context "when an invalid sort strategy is specified" do
      let(:job_sort) { "worst_listing" }
      it "uses the default search replica" do
        expect(subject.search_replica).to eql("#{Indexable::INDEX_NAME}_publish_on_desc")
      end
    end

    context "when a valid non-default sort strategy is specified" do
      let(:job_sort) { "expires_at_desc" }
      it "uses the specified search replica" do
        expect(subject.search_replica).to eql("#{Indexable::INDEX_NAME}_expires_at_desc")
      end

      context "and a keyword is specified" do
        let(:keyword) { "maths teacher" }
        it "uses the specified search replica" do
          expect(subject.search_replica).to eql("#{Indexable::INDEX_NAME}_expires_at_desc")
        end
      end
    end
  end
end
