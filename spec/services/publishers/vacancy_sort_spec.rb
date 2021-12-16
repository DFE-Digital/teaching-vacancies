require "rails_helper"

RSpec.describe Publishers::VacancySort do
  subject { described_class.new(organisation, vacancy_type) }

  let(:organisation) { build_stubbed(:school) }
  let(:vacancy_type) { "published" }

  describe "#initialize" do
    it "sets the column and order of the first sort option by default" do
      expect(subject.column).to eq "expires_at"
      expect(subject.order).to eq "asc"
    end
  end

  describe "#options" do
    context "when vacancy_type is not valid" do
      let(:vacancy_type) { "any_old_type" }

      it "defaults to published sort options" do
        expect(subject.map(&:column)).to eq %w[expires_at job_title]
      end
    end

    context "for a SchoolGroup" do
      let(:organisation) { build_stubbed(:school_group) }

      it "appends readable_job_location to sort options" do
        expect(subject.map(&:column)).to eq %w[expires_at job_title readable_job_location]
      end
    end
  end

  describe "#update" do
    context "when the sort column is valid" do
      let(:column) { "publish_on" }
      let(:vacancy_type) { "pending" }

      it "updates the sort column" do
        expect(subject.update(column: column).column).to eq "publish_on"
      end

      it "updates the sort order" do
        expect(subject.update(column: column).order).to eq "desc"
      end
    end

    context "when the column is invalid" do
      let(:column) { "something_nasty" }

      it "does not update the sort column" do
        expect(subject.update(column: column).column).to eq "expires_at"
      end

      it "does not update the sort order" do
        expect(subject.update(column: column).order).to eq "asc"
      end
    end

    context "when the column is blank" do
      let(:column) { nil }

      it "does not update the sort column" do
        expect(subject.update(column: column).column).to eq "expires_at"
      end

      it "does not update the sort order" do
        expect(subject.update(column: column).order).to eq "asc"
      end
    end
  end
end
