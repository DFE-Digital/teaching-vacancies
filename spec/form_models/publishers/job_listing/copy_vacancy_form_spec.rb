require "rails_helper"

RSpec.describe Publishers::JobListing::CopyVacancyForm, type: :model do
  subject { described_class.new({ job_title: }, build_stubbed(:vacancy)) }

  it { is_expected.to validate_presence_of(:job_title) }
  it { is_expected.to validate_length_of(:job_title).is_at_least(4).is_at_most(100) }

  it { is_expected.to allow_value("Job &amp; another job").for(:job_title) }
  it { is_expected.not_to allow_value("Title with <p>tags</p>").for(:job_title).with_message(I18n.t("job_details_errors.job_title.invalid_characters")) }

  let(:job_title) { "New job title" }

  describe "#params_to_save" do
    it "includes the job_title" do
      expect(subject.params_to_save).to include(job_title:)
    end
  end
end
