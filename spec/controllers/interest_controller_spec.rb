require "rails_helper"

RSpec.describe InterestsController, type: :controller do
  describe "GET #new" do
    let(:school) { create(:school) }

    it "redirects to the vacancy application link" do
      vacancy = create(:vacancy, application_link: "http://foo.com")
      vacancy.organisation_vacancies.create(organisation: school)

      get :new, params: { job_id: vacancy.id }

      expect(request).to redirect_to("http://foo.com")
    end
  end
end
