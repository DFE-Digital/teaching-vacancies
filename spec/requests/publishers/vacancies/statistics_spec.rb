require "rails_helper"

RSpec.describe "Job listing statistics" do
  let(:organisation) { build(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }

  before do
    allow_any_instance_of(Publishers::AuthenticationConcerns).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end

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
