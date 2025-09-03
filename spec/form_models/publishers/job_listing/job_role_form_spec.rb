require "rails_helper"

RSpec.describe Publishers::JobListing::JobRoleForm, type: :model do
  it { is_expected.to validate_presence_of(:job_roles) }

  describe "job_roles validation" do
    subject(:form) { described_class.new(job_roles:) }

    DraftVacancy.job_roles.each_key do |role|
      context "when job_roles contains #{role}" do
        let(:job_roles) { [role] }

        it { expect(form).to be_valid }
      end
    end

    context "when job role invalid" do
      let(:job_roles) { %w[invalid] }

      it { expect(form).not_to be_valid }
    end
  end
end
