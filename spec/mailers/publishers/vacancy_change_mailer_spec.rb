require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe Publishers::VacancyChangeMailer do
  let(:publisher) { create(:publisher) }

  describe "#notify" do
    let(:mail) { described_class.notify(publisher:) }
    let(:some_content) { I18n.t("publishers.vacancy_change_mailer.notify.content").split("\n") }
    let(:footer) { I18n.t("publishers.vacancy_change_mailer.notify.footer", link: "").split("\n") }

    it "sends a `notification` email" do
      expect(mail.subject).to eq(I18n.t("publishers.vacancy_change_mailer.notify.subject"))
      expect(mail.to).to eq([publisher.email])
      expect(mail.body).to include(publisher.given_name)
                      .and include(*some_content)
                      .and include(*footer)
    end
  end
end
