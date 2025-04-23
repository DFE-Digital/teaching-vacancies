require "rails_helper"

RSpec.describe "Job listing statistics" do
  let(:organisation) { build(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }
  let(:vacancy_stats) { double(number_of_unique_views: 42) }

  before do
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    allow(Publishers::VacancyStats).to receive(:new).and_return(vacancy_stats)
    sign_in(publisher, scope: :publisher)
  end

  after { sign_out(publisher) }

  describe "GET #show" do
    context "when csv format is requested" do
      it "returns a csv" do
        get(organisation_job_statistics_path(vacancy.id, format: :csv))
        expect(response.content_type).to include("text/csv")
        expect(response.body).to include("Organisation,Job title,Views by jobseekers")
      end
    end

    context "when no format is specified" do
      it "returns an html page" do
        get(organisation_job_statistics_path(vacancy.id))
        expect(response.content_type).to include("text/html")
        expect(response.body).to include(I18n.t("buttons.download_stats"))
      end
    end
  end
end
