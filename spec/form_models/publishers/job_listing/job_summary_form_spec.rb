require "rails_helper"

RSpec.describe Publishers::JobListing::JobSummaryForm, type: :model do
  subject { described_class.new(params, build_stubbed(:vacancy, job_location:)) }

  let(:params) { {} }
  let(:job_location) { "at_one_school" }

  it { is_expected.to validate_presence_of(:job_advert) }

  context "when vacancy job_location is at_one_school" do
    let(:job_location) { "at_one_school" }

    it { is_expected.to validate_presence_of(:about_school).with_message(I18n.t("job_summary_errors.about_school.blank", organisation: "school")) }
  end

  context "when vacancy job_location is central_office" do
    let(:job_location) { "central_office" }

    it { is_expected.to validate_presence_of(:about_school).with_message(I18n.t("job_summary_errors.about_school.blank", organisation: "trust")) }
  end

  context "when vacancy job_location is at_multiple_schools" do
    let(:job_location) { "at_multiple_schools" }

    it { is_expected.to validate_presence_of(:about_school).with_message(I18n.t("job_summary_errors.about_school.blank", organisation: "schools")) }
  end
end
