require "rails_helper"

RSpec.describe "Subscriptions", type: :request do
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }
  let(:origin) { "/jobs/#{vacancy.id}/#{vacancy.slug}" }

  describe "GET #new with origin param" do
    it "triggers a `vacancy_create_job_alert_clicked` event" do
      expect { get new_subscription_path(origin: origin) }
        .to have_triggered_event(:vacancy_create_job_alert_clicked)
        .and_data(vacancy_id: vacancy.id)
    end
  end
end
