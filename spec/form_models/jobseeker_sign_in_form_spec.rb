require "rails_helper"

RSpec.describe JobseekerSignInForm, type: :model do
  let(:jobseeker) { create(:jobseeker) }
  let(:email) { jobseeker.email }
  let(:password) { jobseeker.password }
  let(:params) { { email: email, password: password } }
  let(:subject) { JobseekerSignInForm.new(params) }

  describe "#email" do
    context "when email is blank" do
      let(:email) { nil }

      it "raises correct error message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:email]).to include(
          I18n.t("activemodel.errors.models.jobseeker_sign_in_form.attributes.email.blank"),
        )
      end
    end

    context "when contact_email is in an invalid format" do
      let(:email) { "💅" }

      it "raises correct error message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:email]).to include(
          I18n.t("activemodel.errors.models.jobseeker_sign_in_form.attributes.email.invalid"),
        )
      end
    end
  end

  describe "#password" do
    context "when password is blank" do
      let(:password) { nil }

      it "raises correct error message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:password]).to include(
          I18n.t("activemodel.errors.models.jobseeker_sign_in_form.attributes.password.blank"),
        )
      end
    end
  end
end
