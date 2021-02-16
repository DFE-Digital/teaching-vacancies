require "rails_helper"

RSpec.describe "Saved jobs", type: :request do
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }
  let(:jobseeker) { create(:jobseeker) }

  before { sign_in(jobseeker, scope: :jobseeker) }

  describe "GET #new" do
    it "triggers a `vacancy_save_to_account_clicked` event" do
      expect { get new_jobseekers_saved_job_path(vacancy.id) }
        .to have_triggered_event(:vacancy_save_to_account_clicked)
        .and_data(vacancy_id: vacancy.id)
    end
  end
end
