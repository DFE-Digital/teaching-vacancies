require "rails_helper"

RSpec.describe Publishers::JobListing::JobDetailsForm, type: :model do
  it { is_expected.to validate_presence_of(:job_title) }
  it { is_expected.to validate_length_of(:job_title).is_at_least(4).is_at_most(100) }

  it { is_expected.to allow_value("Job &amp; another job").for(:job_title) }
  it { is_expected.not_to allow_value("Title with <p>tags</p>").for(:job_title).with_message(I18n.t("job_details_errors.job_title.invalid_characters")) }

  it { is_expected.to validate_inclusion_of(:contract_type).in_array(Vacancy.contract_types.keys) }

  context "when contract_type is fixed_term" do
    before { allow(subject).to receive(:contract_type).and_return("fixed_term") }

    it { is_expected.to validate_presence_of(:contract_type_duration) }
  end

  context "when key stages is not present" do
    it { is_expected.to allow_value([]).for(:key_stages) }
  end

  it { is_expected.to validate_inclusion_of(:key_stages).in_array(Vacancy.key_stages.keys) }
end
