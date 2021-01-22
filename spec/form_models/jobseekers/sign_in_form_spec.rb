require "rails_helper"

RSpec.describe Jobseekers::SignInForm, type: :model do
  subject { described_class.new(params) }

  let(:jobseeker) { create(:jobseeker) }
  let(:email) { jobseeker.email }
  let(:password) { jobseeker.password }
  let(:params) { { email: email, password: password } }

  describe "#email" do
    context "when email is blank" do
      let(:email) { nil }

      it "raises correct error message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:email]).to include(I18n.t("jobseeker_sign_in_errors.email.blank"))
      end
    end

    context "when contact_email is in an invalid format" do
      let(:email) { "💅" }

      it "raises correct error message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:email]).to include(I18n.t("jobseeker_sign_in_errors.email.invalid"))
      end
    end
  end

  describe "#password" do
    context "when password is blank" do
      let(:password) { nil }

      it "raises correct error message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:password]).to include(I18n.t("jobseeker_sign_in_errors.password.blank"))
      end
    end
  end
end
