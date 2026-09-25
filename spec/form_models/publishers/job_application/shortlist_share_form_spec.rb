require "rails_helper"

RSpec.describe Publishers::JobApplication::ShortlistShareForm, type: :model do
  subject(:form) { described_class.new(email:, job_application_ids:) }

  let(:email) { "hiring.manager@example.com" }
  let(:job_application_ids) { Array.new(2) { SecureRandom.uuid } }

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:email) }

  it { is_expected.to allow_value("hiring.manager@example.com").for(:email) }

  it { is_expected.not_to allow_value("not-an-email").for(:email) }

  context "without an application" do
    let(:job_application_ids) { [] }

    it { is_expected.not_to be_valid }
  end

  context "with more than 8 applications" do
    let(:job_application_ids) { Array.new(9) { SecureRandom.uuid } }

    it "shows the selection limit" do
      expect(form).not_to be_valid
      expect(form.errors[:job_application_ids]).to include("Select no more than 8 applications to share")
    end
  end
end
