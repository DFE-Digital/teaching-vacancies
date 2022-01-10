require "rails_helper"

RSpec.describe Publishers::VacancyStatisticsForm, type: :model do
  subject { described_class.new(params) }

  let(:params) { { hired_status:, listed_elsewhere: } }

  let(:hired_status) { "hired_tvs" }
  let(:listed_elsewhere) { "not_listed" }

  describe "#all_questions_completed" do
    context "when hired_status is blank" do
      let(:hired_status) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:base]).to include(I18n.t("errors.publishers.job_statistics.base_error"))
      end

      context "when hired_status and listed_elsewhere are blank" do
        let(:listed_elsewhere) { "" }

        it "validates presence of managed_organisations or managed_school_ids" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:base]).to include(I18n.t("errors.publishers.job_statistics.base_error"))
        end
      end
    end

    context "when only listed_elsewhere is blank" do
      let(:listed_elsewhere) { "" }

      it "validates presence of managed_organisations or managed_school_ids" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:base]).to include(I18n.t("errors.publishers.job_statistics.base_error"))
      end
    end
  end
end
