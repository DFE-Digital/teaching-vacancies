require "rails_helper"

RSpec.describe Search::SimilarJobs do
  subject { described_class.new(vacancy) }

  let(:school) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [school]) }

  it "calls Search::CriteriaDeviser" do
    expect(Search::CriteriaInventor).to receive(:new).with(vacancy).and_call_original
    subject.similar_jobs
  end

  it "calls Search::VacancySearch" do
    expect(Search::VacancySearch).to receive(:new).and_call_original
    subject.similar_jobs
  end

  context "when the vacancy is ect_suitable" do
    # An ect_suitable vacancy makes CriteriaInventor include both `ect_statuses` and `location`,
    # which makes the similar jobs search sort by distance. Regression test for a bug where the
    # ect_statuses filter scope carried a `.distinct` that clashed with `pluck(:id)` on a query
    # ordered by ST_Distance (PG::InvalidColumnReference).
    let(:vacancy) { create(:vacancy, organisations: [school], ect_status: "ect_suitable") }

    it "does not raise PG::InvalidColumnReference" do
      expect { subject.similar_jobs }.not_to raise_error
    end
  end
end
