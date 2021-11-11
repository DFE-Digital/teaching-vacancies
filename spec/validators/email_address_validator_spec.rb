require "rails_helper"

# These rules are based on the validations within GOV.UK Notify
# https://github.com/alphagov/notifications-utils/blob/48c6c822e85d0d1893d2c239e14706cfe0ad8e16/notifications_utils/__init__.py#L6-L19
# https://github.com/alphagov/notifications-utils/blob/efce418c6797409a7a42cf8fa58230e55a6a5938/notifications_utils/recipients.py#L494-L534
RSpec.describe EmailAddressValidator do
  subject(:validator) { described_class }

  let(:email_address) { nil }

  it "behaves like a Rails validator" do
    expect(Jobseekers::SignInForm.new(email: "test@example.com", password: "password")).to be_valid
    expect(Jobseekers::SignInForm.new(email: "test@example", password: "password")).not_to be_valid
  end

  it "can supply an error message translation to a form" do
    form = Jobseekers::SubscriptionForm.new(email: "test")
    form.valid?
    expect(form.errors.messages[:email].first).to eq("Enter an email address in the correct format, like name@example.com")
  end

  context "with a valid email address" do
    let(:email_address) { "test@example.com" }

    it { is_expected.to be_valid(email_address) }
  end

  context "with invalid characters in the local part" do
    let(:email_address) { "test€@example.com" }

    it { is_expected.not_to be_valid(email_address) }
  end

  context "with invalid characters in the hostname part" do
    let(:email_address) { "test@@example.com" }

    it { is_expected.not_to be_valid(email_address) }
  end

  context "with `..` in the local part" do
    let(:email_address) { "te..st@example.com" }

    it { is_expected.not_to be_valid(email_address) }
  end

  context "with `..` in the hostname part" do
    let(:email_address) { "test@exa..mple.com" }

    it { is_expected.not_to be_valid(email_address) }
  end

  context "if it's too long" do
    let(:email_address) { "#{'a' * 250}@#{'b' * 250}.com" }

    it { is_expected.not_to be_valid(email_address) }
  end

  context "if the overall host part is too long" do
    let(:email_address) { "test@#{'b' * 254}.com" }

    it { is_expected.not_to be_valid(email_address) }
  end

  context "if a hostname part is too long" do
    let(:email_address) { "test@test.#{'b' * 64}.com" }

    it { is_expected.not_to be_valid(email_address) }
  end

  context "if there's too few hostname parts" do
    let(:email_address) { "test@example" }

    it { is_expected.not_to be_valid(email_address) }
  end

  context "if there's an empty hostname part" do
    let(:email_address) { "test@.example.com" }

    it { is_expected.not_to be_valid(email_address) }
  end

  context "if there's an empty TLD" do
    let(:email_address) { "test@example." }

    it { is_expected.not_to be_valid(email_address) }
  end
end
