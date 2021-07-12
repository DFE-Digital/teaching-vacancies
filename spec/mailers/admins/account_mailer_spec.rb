require "rails_helper"

RSpec.describe Admins::AccountMailer do
  let(:account_request) { create(:account_request) }

  describe "#account_creation_request" do
    let(:mail) { described_class.account_creation_request(account_request) }
    let(:notify_template) { NOTIFY_ADMIN_ACCOUNT_CREATION_REQUEST_TEMPLATE }

    it "sends an `account_closed` email" do
      expect(mail.subject).to eq(I18n.t("admins.account_mailer.account_creation_request.subject"))
      expect(mail.to).to eq([I18n.t("help.email")])
      expect(mail.body.encoded).to include(account_request.full_name)
      expect(mail.body.encoded).to include(account_request.email)
      expect(mail.body.encoded).to include(account_request.organisation_name)
      expect(mail.body.encoded).to include(account_request.organisation_identifier)
    end
  end
end
