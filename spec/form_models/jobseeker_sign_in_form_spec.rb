require "rails_helper"

RSpec.describe JobseekerSignInForm, type: :model do
  let(:jobseeker) { create(:jobseeker) }
  let(:email) { jobseeker.email }
  let(:password) { jobseeker.password }
  let(:params) { { email: email, password: password } }
  let(:subject) { JobseekerSignInForm.new(alert, params) }
  let(:alert) { "Click here to win a prize!" }

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

  describe "#authenticate" do
    context "when there are no other errors" do
      context "when Devise adds a flash alert about failed authentication" do
        let(:alert) { I18n.t("devise.failure.not_found_in_database") }

        it "converts the message into the govuk error summary component and highlights the first field" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:email]).to include(alert)
        end
      end

      context "when there is a different kind of flash message" do
        it "does not add an authentication error" do
          expect(subject).to be_valid
          expect(subject.errors.messages).to be_blank
        end
      end
    end

    context "when there are other errors" do
      let(:password) { nil }

      it "does not add an authentication error" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:password]).to include(
          I18n.t("activemodel.errors.models.jobseeker_sign_in_form.attributes.password.blank"),
        )
        expect(subject.errors.messages[:email]).to be_blank
      end
    end
  end
end
