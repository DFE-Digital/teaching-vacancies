require "rails_helper"

RSpec.describe Publishers::JobListing::JobSummaryForm, type: :model do
  subject { described_class.new(params, vacancy) }
  let(:params) { {} }
  let(:vacancy) { create(:vacancy, :at_one_school) }

  it { is_expected.to validate_presence_of(:job_advert) }

  context "when no value has been provided for about_school" do
    context "when the vacancy is at one school" do
      it { is_expected.to validate_presence_of(:about_school).with_message(I18n.t("job_summary_errors.about_school.blank", organisation: "school")) }
    end

    context "when the vacancy is at the trust's central office" do
      let(:vacancy) { create(:vacancy, :central_office) }

      it { is_expected.to validate_presence_of(:about_school).with_message(I18n.t("job_summary_errors.about_school.blank", organisation: "trust")) }
    end

    context "when the vacancy is at multiple schools" do
      let(:vacancy) { create(:vacancy, :at_multiple_schools) }

      it { is_expected.to validate_presence_of(:about_school).with_message(I18n.t("job_summary_errors.about_school.blank", organisation: "schools")) }
    end
  end
end
