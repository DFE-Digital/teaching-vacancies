require "rails_helper"

RSpec.describe "Jobseekers can view organisation landing pages" do
  let(:school) { create(:school, name: "Hogwarts School of Witchcraft and Wizardry") }
  let!(:vacancy) { create(:vacancy, job_title: "Head of Hogwarts", organisations: [school]) }

  context "when the organisation is a school" do
    it "contains the expected content and vacancies" do
      visit organisation_landing_page_path(school.slug)

      expect(page.title).to eq("School & Teaching Jobs at #{school.name} - Teaching Vacancies")
      expect(page).to have_css("h1", text: "1 job found at #{school.name}")
      expect(page).to have_link(vacancy.job_title.to_s)
      expect(page).to have_link(school.name, href: organisation_landing_page_path(school.slug))
    end
  end

  context "when the organisation is a school group" do
    let(:school_group) { create(:school_group, name: "Wizarding MAT", schools: [school]) }
    let!(:vacancy2) { create(:vacancy, job_title: "Wizarding MAT Admin", organisations: [school_group]) }

    it "contains the expected content and vacancies" do
      visit organisation_landing_page_path(school_group.slug)

      expect(page.title).to eq("School & Teaching Jobs at #{school_group.name} - Teaching Vacancies")

      expect(page).to have_css("h1", text: "2 jobs found at #{school_group.name}")
      expect(page).to have_link(vacancy.job_title.to_s)
      expect(page).to have_link(vacancy2.job_title.to_s)
      expect(page).to have_link(school.name, href: organisation_landing_page_path(school.slug))
      expect(page).to have_link(school_group.name, href: organisation_landing_page_path(school_group.slug))
    end
  end

  context "when clicking on an organisation link from the search results page" do
    it "takes you to the organisation landing page" do
      visit root_path
      click_on I18n.t("buttons.search")
      click_on school.name
      expect(current_path).to eq(organisation_landing_page_path(school.slug))
    end
  end
end
