require "rails_helper"

RSpec.describe "Viewing a single published vacancy" do
  let(:school) { create(:school) }

  scenario "Published vacancies are viewable" do
    vacancy = create(:vacancy, :published)
    vacancy.organisation_vacancies.create(organisation: school)

    published_vacancy = VacancyPresenter.new(vacancy)

    visit job_path(published_vacancy)

    verify_vacancy_show_page_details(published_vacancy)
  end

  scenario "Unpublished vacancies are not accessible" do
    vacancy = create(:vacancy, :draft)
    vacancy.organisation_vacancies.create(organisation: school)

    draft_vacancy = VacancyPresenter.new(vacancy)

    visit job_path(draft_vacancy)

    expect(page).to have_content("Page not found")
    expect(page).to_not have_content(draft_vacancy.job_title)
  end

  scenario "Job post with a future publish_on date are not accessible" do
    vacancy = create(:vacancy, :future_publish)
    vacancy.organisation_vacancies.create(organisation: school)

    visit job_path(vacancy)

    expect(page).to have_content("Page not found")
    expect(page).to_not have_content(vacancy.job_title)
  end

  scenario "Expired vacancies display a warning message" do
    current_vacancy = create(:vacancy)
    current_vacancy.organisation_vacancies.create(organisation: school)
    expired_vacancy = build(:vacancy, :expired)
    expired_vacancy.send :set_slug
    expired_vacancy.save(validate: false)
    expired_vacancy.organisation_vacancies.create(organisation: school)

    visit job_path(current_vacancy)
    expect(page).to have_no_content("This job post has expired")

    visit job_path(expired_vacancy)
    expect(page).to have_content("This job post has expired")
  end

  scenario "A single vacancy must contain JobPosting schema.org mark up" do
    vacancy = create(:vacancy, :job_schema)
    vacancy.organisation_vacancies.create(organisation: school)

    visit job_path(vacancy)

    expect(script_tag_content(wrapper_class: ".jobref"))
      .to eq(vacancy_json_ld(VacancyPresenter.new(vacancy)).to_json)
  end

  scenario "A vacancy without a job role" do
    vacancy = build(:vacancy, job_roles: nil)
    vacancy.send :set_slug
    vacancy.save(validate: false)
    vacancy.organisation_vacancies.create(organisation: school)

    visit job_path(vacancy)
    expect(page).to have_content(vacancy.job_title)
    expect(page).to_not have_content(I18n.t("jobs.job_roles_html"))
  end

  context "A user viewing a vacancy" do
    context "when creating a job alert" do
      let(:vacancy) { create(:vacancy, subjects: %w[Physics]) }

      before do
        vacancy.organisation_vacancies.create(organisation: school)
        visit job_path(vacancy)
      end

      scenario "can click on the first link to create a job alert" do
        click_on I18n.t("jobs.alert.similar.terse")
        expect(page).to have_content(I18n.t("subscriptions.new.title"))
        expect(page.find_field("jobseekers-subscription-form-keyword-field").value).to eq("Physics")
        expect(page.find_field("jobseekers-subscription-form-location-field").value).to eq(school.postcode)
        expect(page.find_field("jobseekers-subscription-form-radius-field").value).to eq("10")
      end

      scenario "can click on the second link to create a job alert" do
        click_on I18n.t("jobs.alert.similar.verbose.link_text")
        expect(page).to have_content(I18n.t("subscriptions.new.title"))
        expect(page.find_field("jobseekers-subscription-form-keyword-field").value).to eq("Physics")
        expect(page.find_field("jobseekers-subscription-form-location-field").value).to eq(school.postcode)
        expect(page.find_field("jobseekers-subscription-form-radius-field").value).to eq("10")
      end
    end

    scenario "can click on the application link when there is one set" do
      vacancy = create(:vacancy, :job_schema, :no_tv_applications)
      vacancy.organisation_vacancies.create(organisation: school)

      visit job_path(vacancy)

      click_on I18n.t("jobs.apply")

      expect(page.current_url).to eq vacancy.application_link
    end

    context "with supporting documents attached" do
      before do
        vacancy = create(:vacancy, :published)
        vacancy.organisation_vacancies.create(organisation: school)
        visit job_path(vacancy)
      end

      scenario "can see the supporting documents section" do
        expect(page).to have_content(I18n.t("jobs.supporting_documents"))
        expect(page).to have_content("Test.png")
      end
    end

    scenario "the page view is tracked" do
      vacancy = create(:vacancy, :published)
      vacancy.organisation_vacancies.create(organisation: school)

      expect { visit job_path(vacancy) }.to have_enqueued_job(PersistVacancyPageViewJob).with(vacancy.id)
    end
  end

  context "meta tags" do
    include ActionView::Helpers::SanitizeHelper
    scenario "the vacancy's meta data are rendered correctly" do
      vacancy = create(:vacancy, :published)
      vacancy.organisation_vacancies.create(organisation: school)
      vacancy = VacancyPresenter.new(vacancy)
      visit job_path(vacancy)

      expect(page.find('meta[name="description"]', visible: false)["content"])
        .to eq(strip_tags(vacancy.job_advert))
    end

    scenario "the vacancy's open graph meta data are rendered correctly" do
      vacancy = create(:vacancy, :published)
      vacancy.organisation_vacancies.create(organisation: school)
      vacancy = VacancyPresenter.new(vacancy)
      visit job_path(vacancy)

      expect(page.find('meta[property="og:description"]', visible: false)["content"])
        .to eq(strip_tags(vacancy.job_advert))
    end
  end
end
