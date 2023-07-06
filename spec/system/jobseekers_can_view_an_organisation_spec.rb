require "rails_helper"

RSpec.describe "Viewing an organisation" do
  let(:school_group) { create(:trust) }
  let(:organisation) { create(:school, school_groups: [school_group]) }
  let!(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let!(:vacancy_without_apply) { create(:vacancy, :no_tv_applications, organisations: [organisation]) }

  before do
    Organisation.subclasses.each do |klass|
      allow_any_instance_of(klass).to receive(:geopoint?).and_return(true)
    end

    visit organisation_path(organisation)
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

  it "flags the jobs that allow applications through Teaching Vacancies" do
    expect(page.find("h3 a", text: vacancy.job_title))
      .to have_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
    expect(page.find("h3 a", text: vacancy_without_apply.job_title))
      .not_to have_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
  end

  it "has a map showing the organisation's location" do
    has_organisation_map?
  end

  it "can create a job alert for jobs at the organisation" do
    has_button_to_create_job_alert?(organisation)

    click_on I18n.t("organisations.show.job_alert.button")

    expect(current_path).to eq(new_subscription_path)
  end

  context "when the organisation is part of a school group" do
    it "has a link to the school group's profile" do
      expect(page).to have_link(href: organisation_path(school_group))

      click_on school_group.name

      expect(current_path).to eq(organisation_path(school_group))
    end
  end

  context "when the organisation is a school group" do
    let(:organisation) { create(:trust, schools: [school_one, school_two]) }
    let!(:vacancy) { create(:vacancy, organisations: [organisation]) }
    let(:school_one) { create(:school) }
    let(:school_two) { create(:school) }

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

    it "flags the jobs that allow applications through Teaching Vacancies" do
      expect(page.find("h3 a", text: vacancy.job_title))
        .to have_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
      expect(page.find("h3 a", text: vacancy_without_apply.job_title))
        .not_to have_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
    end

    it "has a map showing the organisation's location" do
      has_organisation_map?
    end

    it "can create a job alert for jobs at the organisation" do
      has_button_to_create_job_alert?(organisation)

      click_on I18n.t("organisations.show.job_alert.button")

      expect(current_path).to eq(new_subscription_path)
    end

    it "displays a list of schools associated with the school group" do
      within(".organisation-navigation") do
        expect(page).to have_content(I18n.t("organisations.show.tabs.schools"))

        click_on I18n.t("organisations.show.tabs.schools")
      end

      organisation.schools.each do |school|
        expect(page).to have_content(school.name)
        expect(page).to have_link(href: organisation_path(school))
      end
    end
  end
end
