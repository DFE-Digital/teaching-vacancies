require "rails_helper"

RSpec.describe Publishers::VacancySort do
  subject { described_class.new(organisation, vacancy_type) }

  let(:organisation) { build_stubbed(:school) }
  let(:vacancy_type) { :live }

  describe "#initialize" do
    it "sets the column and order of the first sort option by default" do
      expect(subject.sort_by).to eq "expires_at"
      expect(subject.order).to eq "asc"
    end
  end

  describe "#update" do
    context "when the sort column is valid" do
      let(:sort_by) { "publish_on" }
      let(:vacancy_type) { :pending }

      it "updates the sort column" do
        expect(subject.update(sort_by: sort_by).sort_by).to eq "publish_on"
      end

      it "updates the sort order" do
        expect(subject.update(sort_by: sort_by).order).to eq "desc"
      end
    end

    context "when the column is invalid" do
      let(:sort_by) { "something_nasty" }

      it "does not update the sort column" do
        expect(subject.update(sort_by: sort_by).sort_by).to eq "expires_at"
      end

      it "does not update the sort order" do
        expect(subject.update(sort_by: sort_by).order).to eq "asc"
      end
    end

    context "when the column is blank" do
      let(:sort_by) { nil }

      it "does not update the sort column" do
        expect(subject.update(sort_by: sort_by).sort_by).to eq "expires_at"
      end

      it "does not update the sort order" do
        expect(subject.update(sort_by: sort_by).order).to eq "asc"
      end
    end
  end
end
