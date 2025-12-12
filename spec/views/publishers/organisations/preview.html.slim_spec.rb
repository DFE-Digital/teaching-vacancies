require "rails_helper"

RSpec.describe "publishers/organisations/preview" do
  before do
    assign :organisation, organisation
    assign :vacancies, vacancies
    render
  end

  context "when the organisation is a school" do
    let(:organisation) { build_stubbed(:school) }
    let(:vacancies) { build_stubbed_list(:vacancy, 1, organisations: [organisation]) }

    it "displays a profile summary" do
      has_profile_summary?(rendered, organisation)
    end

    it "displays the organisation's description" do
      expect(rendered).to have_content(organisation.description)
    end

    it "displays the organisation's safeguarding information" do
      expect(rendered).to have_content(organisation.safeguarding_information)
    end

    it "has a list of live jobs at the organisation" do
      has_list_of_live_jobs?(rendered, vacancies)
    end

    it "has a map showing the organisation's location" do
      expect(rendered).to have_content(I18n.t("organisations.map.heading"))
    end

    it "has a button to create a job alert" do
      has_button_to_create_job_alert?(rendered, organisation)
    end
  end

  context "when the organisation is a school group" do
    let(:trust) { build_stubbed(:trust, :with_geopoint, schools: [school_one, school_two]) }
    let(:vacancies) { build_stubbed_list(:vacancy, 1, organisations: [trust]) }
    let(:school_one) { build_stubbed(:school, name: "Test school one") }
    let(:school_two) { build_stubbed(:school, name: "Test school two") }
    let(:organisation) { trust }

    it "displays a profile summary" do
      has_profile_summary?(rendered, organisation)
    end

    it "displays the organisation's description" do
      expect(rendered).to have_content(organisation.description)
    end

    it "displays the organisation's safeguarding information" do
      expect(rendered).to have_content(organisation.safeguarding_information)
    end

    it "has a list of live jobs at the organisation" do
      has_list_of_live_jobs?(rendered, vacancies)
    end

    it "has a map showing the organisation's location" do
      expect(rendered).to have_content(I18n.t("organisations.map.heading"))
    end

    it "has a button to create a job alert for jobs at the organisation" do
      has_button_to_create_job_alert?(rendered, organisation)
    end

    context "when viewing one of the school group's schools" do
      let(:trust) { create(:trust, schools: [school_one, school_two]) }
      let(:school_one) { create(:school, name: "Test school one") }
      let(:school_two) { create(:school, name: "Test school two") }
      let(:organisation) { school_one }

      before do
        create(:vacancy, organisations: [trust])
      end

      it "displays the school's profile" do
        has_profile_summary?(rendered, school_one)
      end

      it "displays the organisation's description" do
        expect(rendered).to have_content(school_one.description)
      end

      it "displays the organisation's safeguarding information" do
        expect(rendered).to have_content(school_one.safeguarding_information)
      end

      it "has a list of live jobs at the school" do
        has_list_of_live_jobs?(rendered, school_one.vacancies)
      end

      it "has a map showing the school's location" do
        expect(rendered).to have_content(I18n.t("organisations.map.heading"))
      end

      it "has a button to create a job alert for jobs at the school" do
        has_button_to_create_job_alert?(rendered, school_one)
      end

      it "has a link to the preview of its parent orgnisation's profile" do
        expect(rendered).to have_link(href: publishers_organisation_preview_path(trust))
      end
    end
  end
end
