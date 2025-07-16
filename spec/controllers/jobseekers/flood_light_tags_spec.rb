require "rails_helper"

# Please notify performance analyst (currently Brandon) if you change this test
# as it reflects the binding between the application and the Floodlight tags in GA
RSpec.describe VacanciesController do
  render_views

  before do
    # The application form is behind a login now
    sign_in create(:jobseeker), scope: :jobseeker

    get :show, params: { id: vacancy }
  end

  after { sign_out :jobseeker }

  describe "Apply Button" do
    let(:vacancy) { create(:vacancy) }

    it "has the correct text" do
      expect(response.body).to have_content("Apply for this job")
    end
  end

  describe "View advert on school website" do
    let(:vacancy) { create(:vacancy, :no_tv_applications) }

    it "has the correct text" do
      expect(response.body).to have_content("View advert on school website (opens in new tab)")
    end
  end

  describe "Download an application form" do
    let(:vacancy) { create(:vacancy, :with_application_form) }

    it "has the correct text" do
      expect(response.body).to have_content("Download an application form - ")
    end
  end

  describe "View advert on external website" do
    let(:vacancy) { create(:vacancy, :external) }

    it "has the correct text" do
      expect(response.body).to have_content("View advert on external website (opens in new tab)")
    end
  end
end
