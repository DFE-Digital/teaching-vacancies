require "rails_helper"

RSpec.describe Publishers::JobListing::CopyVacancyForm, type: :model do
  subject { described_class.new({ job_title: nil }) }

  it { is_expected.to validate_presence_of(:job_title) }
  it { is_expected.to validate_length_of(:job_title).is_at_least(4).is_at_most(100) }

  it { is_expected.to allow_value("Job &amp; another job").for(:job_title) }
  it { is_expected.not_to allow_value("Title with <p>tags</p>").for(:job_title).with_message(I18n.t("job_details_errors.job_title.invalid_characters")) }
end
