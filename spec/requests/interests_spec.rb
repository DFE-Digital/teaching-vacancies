require "rails_helper"

RSpec.describe "Interests" do
  let(:application_link) { "http://foo.com" }
  let(:vacancy) { create(:vacancy, application_link:, organisations: [build(:school)]) }

  describe "GET #new" do
    it "redirects to the vacancy application link" do
      get new_job_interest_path(vacancy.id)

      expect(response).to redirect_to(application_link)
      expect(response).to have_http_status(301)
    end

    it "triggers a `vacancy_get_more_info_clicked` event" do
      expect { get new_job_interest_path(vacancy.id) }
        .to have_triggered_event(:vacancy_get_more_info_clicked)
        .and_data(vacancy_id: anonymised_form_of(vacancy.id))
    end
  end
end
