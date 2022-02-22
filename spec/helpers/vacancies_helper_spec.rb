require "rails_helper"

RSpec.describe VacanciesHelper do
  describe "#vacancy_full_job_location" do
    subject { vacancy_full_job_location(vacancy) }

    context "when job_location is at_multiple_schools" do
      let(:trust) { build(:trust, name: "Magic Trust") }
      let(:vacancy) { build(:vacancy, :at_multiple_schools, organisations: [trust]) }

      it "returns the multiple schools location" do
        expect(subject).to eq("More than one school, Magic Trust")
      end
    end

    context "when job_location is not at_multiple_schools" do
      let(:school) { build(:school, name: "Magic School", town: "Cool Town", county: "Orange County", postcode: "SW1A") }
      let(:vacancy) { build(:vacancy, organisations: [school]) }

      it "returns the full location" do
        expect(subject).to eq("Magic School, Cool Town, Orange County, SW1A")
      end
    end
  end

  describe "#vacancy_breadcrumbs" do
    subject { vacancy_breadcrumbs(vacancy).to_a }
    let(:vacancy) { build_stubbed(:vacancy, job_title: "A Job", job_roles: %w[teacher]) }
    let(:request) { double("request", host: "example.com", referrer: referrer) }
    let(:referrer) { "http://www.example.com/foo" }
    let(:landing_page) { instance_double(LandingPage, title: "Landing Page", slug: "landing") }

    before do
      allow(helper).to receive(:request).and_return(request)
      allow(LandingPage).to receive(:matching).with(job_roles: %w[teacher]).and_return(landing_page)
    end

    it "has the homepage as its first breadcrumb" do
      expect(subject[0].last).to eq(root_path)
    end

    it "has the landing page as its second breadcrumb" do
      expect(subject[1]).to eq(["Landing Page", landing_page_path("landing")])
    end

    it "has the job as its last breadcrumb" do
      expect(subject[2]).to eq([:"A Job", ""])
    end

    context "when the user comes from the search page" do
      let(:referrer) { jobs_url(foo: "bar", host: "example.com") }

      it "has the search as its second breadcrumb" do
        expect(subject[1]).to eq([t("breadcrumbs.jobs"), referrer])
      end
    end

    context "when there is no landing page" do
      let(:landing_page) { nil }

      it "has the expected parent breadcrumb" do
        expect(subject[1]).to eq([t("breadcrumbs.jobs"), jobs_path])
      end
    end
  end
end
