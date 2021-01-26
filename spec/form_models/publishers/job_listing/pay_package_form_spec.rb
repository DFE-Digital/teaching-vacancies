require "rails_helper"

RSpec.describe Publishers::JobListing::PayPackageForm, type: :model do
  it { is_expected.to validate_presence_of(:salary) }
  it { is_expected.to validate_length_of(:salary).is_at_most(256) }
  it { is_expected.to allow_value("Job &amp; another job").for(:salary) }
  it { is_expected.not_to allow_value("Title with <p>tags</p>").for(:salary).with_message(I18n.t("pay_package_errors.salary.invalid_characters")) }
end
