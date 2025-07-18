require "rails_helper"

RSpec.describe "Publishers can filter vacancies in their dashboard" do
  let(:publisher) { create(:publisher) }
  let(:trust) { create(:trust, schools: [school1, school2]) }
  let(:local_authority1) { create(:local_authority, schools: [school1, school2, school4, school5]) }
  let(:local_authority2) { create(:local_authority) }
  let(:school1) { create(:school, name: "Happy Rainbows School") }
  let(:school2) { create(:school, name: "Dreary Grey School") }
  let!(:school_group_vacancy) { create(:vacancy, organisations: [trust], job_title: "Maths Teacher") }
  let!(:school1_vacancy) { create(:vacancy, organisations: [school1], job_title: "English Teacher") }
  let!(:school1_draft_vacancy) { create(:draft_vacancy, organisations: [school1], job_title: "Science Teacher") }
  let!(:school2_draft_vacancy) { create(:draft_vacancy, organisations: [school2], job_title: "History Teacher") }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  after { logout }

  context "when no organisations have been previously selected" do
    let(:organisation) { trust }

    context "when viewing active jobs tab" do
      scenario "it shows all published vacancies" do
        visit organisation_jobs_with_type_path(:live)

        expect(page).to_not have_css(".filters-component__remove-tags__tag")

        expect(page).to have_content(school_group_vacancy.job_title)
        expect(page).to have_content(school1_vacancy.job_title)
        expect(page).to_not have_content(school1_draft_vacancy.job_title)
        expect(page).to_not have_content(school2_draft_vacancy.job_title)
      end

      context "when applying filters" do
        scenario "it shows filtered published vacancies" do
          visit organisation_jobs_with_type_path(:live)

          check "Happy Rainbows School (1)"
          click_on I18n.t("buttons.apply_filters")

          expect(page).to have_css(".filters-component__remove-tags__tag", count: 1)

          expect(page).to_not have_content(school_group_vacancy.job_title)
          expect(page).to have_content(school1_vacancy.job_title)
          expect(page).to_not have_content(school1_draft_vacancy.job_title)
          expect(page).to_not have_content(school2_draft_vacancy.job_title)
        end
      end

      context "when clearing all filters" do
        before do
          PublisherPreference.create(publisher: publisher, organisation: trust, organisations: [school1])
          visit organisation_jobs_with_type_path(:live)
          click_on I18n.t("shared.filter_group.clear_all_filters")
        end

        it "shows all published vacancies again" do
          expect(page).to_not have_css(".filters-component__remove-tags__tag")
          expect(page).to have_content(school_group_vacancy.job_title)
          expect(page).to have_content(school1_vacancy.job_title)
        end
      end
    end

    context "when viewing draft jobs tab" do
      scenario "it shows all draft vacancies" do
        visit organisation_jobs_with_type_path(:draft)

        expect(page).to_not have_css(".filters-component__remove-tags__tag")

        expect(page).to_not have_content(school_group_vacancy.job_title)
        expect(page).to_not have_content(school1_vacancy.job_title)
        expect(page).to have_content(school1_draft_vacancy.job_title)
        expect(page).to have_content(school2_draft_vacancy.job_title)
      end
    end
  end

  context "when organisations have been previously selected" do
    let(:organisation) { trust }
    let!(:publisher_preference_trust) { PublisherPreference.create(publisher: publisher, organisation: trust, organisations: [school1, school2]) }

    scenario "it shows filtered published vacancies" do
      visit organisation_jobs_with_type_path

      expect(page).to have_css(".filters-component__remove-tags__tag", count: 2)

      expect(page).to_not have_content(school_group_vacancy.job_title)
      expect(page).to have_content(school1_vacancy.job_title)
      expect(page).to_not have_content(school1_draft_vacancy.job_title)
      expect(page).to_not have_content(school2_draft_vacancy.job_title)
    end
  end

  context "when organisations is a local authority" do
    let(:local_authorities_extra_schools) { { local_authority1.local_authority_code.to_i => [school3.urn] } }
    let!(:school3) { create(:school) }
    let(:school4) { create(:school, name: "Closed school", establishment_status: "Closed") }
    let(:school5) do
      create(:school, name: "University", gias_data: { "TypeOfEstablishment (code)" => "29" }, detailed_school_type: "Higher education institutions")
    end
    let(:organisation) { local_authority1 }

    before do
      allow(Rails.configuration).to receive(:local_authorities_extra_schools).and_return(local_authorities_extra_schools)
    end

    it "shows filters and results of only the schools that publisher selects in preference page" do
      visit new_publishers_publisher_preference_path
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content(I18n.t("publishers.publisher_preferences.form.missing_schools_error"))
      expect(page).to_not have_content(school4.name)
      expect(page).to_not have_content(school5.name)

      check school1.name
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content("#{school1.name} (1)")
      expect(page).to_not have_content(school2.name)
      expect(page).to_not have_content(school1_draft_vacancy.job_title)
      expect(page).to_not have_content(school2_draft_vacancy.job_title)

      click_on I18n.t("jobs.dashboard.add_or_remove_schools")
      uncheck school1.name
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content(I18n.t("publishers.publisher_preferences.form.missing_schools_error"))

      uncheck school1.name
      check school3.name
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content("#{school3.name} (0)")
      expect(page).to_not have_content(school1.name)
      expect(page).to_not have_content(school2.name)
      expect(page).to_not have_content(school1_draft_vacancy.job_title)
      expect(page).to_not have_content(school2_draft_vacancy.job_title)
    end
  end
end
