require "rails_helper"

RSpec.describe Publishers::JobApplicationDataExpiryMailer do
  let(:email) { "test@example.com" }
  let(:mail) { described_class.with(params).job_application_data_expiry }
  let(:organisation) { create(:school) }
  let(:params) { { vacancy: vacancy, publisher: publisher } }
  let(:publisher) { create(:publisher, email: email) }
  let(:vacancy) { create(:vacancy, publisher: publisher, organisations: [organisation]) }
  let(:vacancy_data_expiration_date) { (vacancy.expires_at + 1.year).to_date }

  describe "#job_application_data_expiry" do
    it "sends a `job_application_data_expiry` email" do
      expect(mail.subject).to eq(I18n.t("publishers.job_application_data_expiry_mailer.job_application_data_expiry.subject", job_title: vacancy.job_title,
                                                                                                                             expiration_date: format_date(vacancy_data_expiration_date)))
      expect(mail.to).to eq(["test@example.com"])
      expect(mail.body.encoded).to include(vacancy.job_title)
                               .and include(I18n.t("publishers.job_application_data_expiry_mailer.job_application_data_expiry.title", job_title: vacancy.job_title,
                                                                                                                                      publish_date: vacancy.publish_on.to_formatted_s(:month_year),
                                                                                                                                      expiration_date: vacancy_data_expiration_date))
                               .and include(I18n.t("publishers.job_application_data_expiry_mailer.job_application_data_expiry.expiry", job_title: vacancy.job_title,
                                                                                                                                       expiration_date: vacancy_data_expiration_date))
      expect(mail.body.to_s).to include(page_url("privacy-policy"))
                            .and include(organisation_job_job_applications_url(vacancy.id))
    end
  end
end
