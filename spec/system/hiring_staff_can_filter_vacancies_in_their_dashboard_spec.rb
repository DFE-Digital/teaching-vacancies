require "rails_helper"

RSpec.describe "Hiring staff can filter vacancies in their dashboard" do
  let(:publisher) { create(:publisher) }
  let(:trust) { create(:trust) }
  let(:local_authority) { create(:local_authority) }
  let(:school1) { create(:school, name: "Happy Rainbows School") }
  let(:school2) { create(:school, name: "Dreary Grey School") }
  let!(:school_group_vacancy) { create(:vacancy, :published, :central_office) }
  let!(:school1_vacancy) { create(:vacancy, :published, :at_one_school) }
  let!(:school1_draft_vacancy) { create(:vacancy, :draft, :at_one_school) }
  let!(:school2_draft_vacancy) { create(:vacancy, :draft, :at_one_school) }
  let!(:publisher_preference_local_authority) { PublisherPreference.create(publisher: publisher, organisation: local_authority) }
  let!(:publisher_preference_trust) { PublisherPreference.create(publisher: publisher, organisation: trust) }

  before do
    login_publisher(publisher: publisher, organisation: trust)

    school_group_vacancy.organisation_vacancies.create(organisation: trust)
    school1_vacancy.organisation_vacancies.create(organisation: school1)
    school1_draft_vacancy.organisation_vacancies.create(organisation: school1)
    school2_draft_vacancy.organisation_vacancies.create(organisation: school2)

    SchoolGroupMembership.create(school: school1, school_group: trust)
    SchoolGroupMembership.create(school: school2, school_group: trust)
  end

  context "when no organisations have been previously selected" do
    context "when viewing active jobs tab" do
      scenario "it shows all published vacancies" do
        visit jobs_with_type_organisation_path(:published)

        expect(page).to_not have_css(".moj-filter__tag")

        expect(page).to have_content(school_group_vacancy.job_title)
        expect(page).to have_content(school1_vacancy.job_title)
        expect(page).to_not have_content(school1_draft_vacancy.job_title)
        expect(page).to_not have_content(school2_draft_vacancy.job_title)
      end

      context "when applying filters" do
        scenario "it shows filtered published vacancies" do
          visit jobs_with_type_organisation_path(:published)

          check "Happy Rainbows School (1)"
          click_on I18n.t("buttons.apply_filters")

          expect(page).to have_css(".moj-filter__tag", count: 1)

          expect(page).to_not have_content(school_group_vacancy.job_title)
          expect(page).to have_content(school1_vacancy.job_title)
          expect(page).to_not have_content(school1_draft_vacancy.job_title)
          expect(page).to_not have_content(school2_draft_vacancy.job_title)
        end
      end
    end

    context "when viewing draft jobs tab" do
      scenario "it shows all draft vacancies" do
        visit jobs_with_type_organisation_path(:draft)

        expect(page).to_not have_css(".moj-filter__tag")

        expect(page).to_not have_content(school_group_vacancy.job_title)
        expect(page).to_not have_content(school1_vacancy.job_title)
        expect(page).to have_content(school1_draft_vacancy.job_title)
        expect(page).to have_content(school2_draft_vacancy.job_title)
      end
    end
  end

  context "when organisations have been previously selected" do
    before do
      OrganisationPublisherPreference.create(organisation: school1, publisher_preference: publisher_preference_trust)
      OrganisationPublisherPreference.create(organisation: school2, publisher_preference: publisher_preference_trust)
    end

    scenario "it shows filtered published vacancies" do
      visit organisation_path

      expect(page).to have_css(".moj-filter__tag", count: 2)

      expect(page).to_not have_content(school_group_vacancy.job_title)
      expect(page).to have_content(school1_vacancy.job_title)
      expect(page).to_not have_content(school1_draft_vacancy.job_title)
      expect(page).to_not have_content(school2_draft_vacancy.job_title)
    end
  end
end
