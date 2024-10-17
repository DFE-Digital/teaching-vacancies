require "rails_helper"

# Please notify performance analyst if you change this test
# as it reflects the binding between the application and the Floodlight tags in GA
RSpec.describe VacanciesController do
  render_views

  before do
    get :show, params: { id: vacancy }
  end

  describe "Apply Button" do
    let(:vacancy) { create(:vacancy) }

    it "has the correct text" do
      expect(response.body).to have_content("Apply for this job")
    end
  end

  describe "How to Apply Button" do
    let(:vacancy) { create(:vacancy, :no_tv_applications) }

    it "has the correct text" do
      expect(response.body).to have_content("How to apply (opens in new tab)")
    end
  end

  describe "Download an application form" do
    let(:vacancy) { create(:vacancy, :with_application_form) }

    it "has the correct text" do
      expect(response.body).to have_content("Download an application form - ")
    end
  end

  describe "View advert on school website" do
    let(:vacancy) { create(:vacancy, :external) }

    it "has the correct text" do
      expect(response.body).to have_content("View advert on school website (opens in new tab)")
    end
  end
end
