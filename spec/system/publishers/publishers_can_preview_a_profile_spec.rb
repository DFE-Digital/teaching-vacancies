require "rails_helper"

RSpec.describe "Publishers can preview an organisation or school profile" do
  let(:publisher) { create(:publisher, organisations: [organisation]) }

  before do
    Organisation.subclasses.each do |klass|
      allow_any_instance_of(klass).to receive(:geopoint?).and_return(true)
    end

    login_publisher(publisher: publisher, organisation: organisation)
    visit publisher_root_path
  end

  context "when the publisher is signed in as a school" do
    let(:organisation) { create(:school) }

    before do
      click_link I18n.t("nav.school_profile")
      click_link I18n.t("publishers.organisations.show.preview_link_text", organisation_type: "school")
    end

    it "displays a profile summary" do
      has_profile_summary?(organisation)
    end

    it "displays the organisation's description" do
      expect(page).to have_content(organisation.description)
    end

    it "displays the organisation's safeguarding information" do
      expect(page).to have_content(organisation.safeguarding_information)
    end

    it "has a list of live jobs at the organisation" do
      has_list_of_live_jobs?(organisation) if organisation.vacancies.any?
    end

    it "has a map showing the organisation's location" do
      has_organisation_map?
    end

    it "has a button to create a job alert" do
      has_button_to_create_job_alert?(organisation)
    end
  end

  context "when the publisher is signed in as a school group" do
    let(:organisation) { create(:trust, schools: [school_one, school_two]) }
    let!(:vacancy) { create(:vacancy, organisations: [organisation]) }
    let(:school_one) { create(:school, name: "Test school one") }
    let(:school_two) { create(:school, name: "Test school two") }

    before do
      click_link I18n.t("nav.organisation_profile")
      click_link I18n.t("publishers.organisations.show.preview_link_text", organisation_type: "organisation")
    end

    it "displays a profile summary" do
      has_profile_summary?(organisation)
    end

    it "displays the organisation's description" do
      expect(page).to have_content(organisation.description)
    end

    it "displays the organisation's safeguarding information" do
      expect(page).to have_content(organisation.safeguarding_information)
    end

    it "has a list of live jobs at the organisation" do
      has_list_of_live_jobs?(organisation)
    end

    it "has a map showing the organisation's location" do
      has_organisation_map?
    end

    it "has a button to create a job alert for jobs at the organisation" do
      has_button_to_create_job_alert?(organisation)
    end

    context "when viewing one of the school group's schools" do
      let!(:vacancy) { create(:vacancy, organisations: [school_one]) }

      before do
        within(".organisation-navigation") do
          click_on I18n.t("organisations.show.tabs.schools")
        end

        click_on school_one.name
      end

      it "displays the school's profile" do
        has_profile_summary?(school_one)
      end

      it "displays the organisation's description" do
        expect(page).to have_content(school_one.description)
      end

      it "displays the organisation's safeguarding information" do
        expect(page).to have_content(school_one.safeguarding_information)
      end

      it "has a list of live jobs at the school" do
        has_list_of_live_jobs?(school_one)
      end

      it "has a map showing the school's location" do
        has_organisation_map?
      end

      it "has a button to create a job alert for jobs at the school" do
        has_button_to_create_job_alert?(school_one)
      end

      it "has a link to the preview of its parent orgnisation's profile" do
        expect(page).to have_link(href: publishers_organisation_preview_path(organisation))
      end

      it "has a link to exit the preview" do
        expect(page).to have_link(href: publishers_organisation_path(school_one))

        click_on I18n.t("publishers.organisations.schools.preview.exit_preview_link_text")

        expect(page).to have_current_path(publishers_organisation_path(school_one), ignore_query: true)
      end
    end
  end
end
