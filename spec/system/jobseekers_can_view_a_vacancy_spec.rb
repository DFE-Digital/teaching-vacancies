require "rails_helper"

RSpec.describe "Viewing a single published vacancy" do
  let(:school) { create(:school) }

  before do
    vacancy.organisation_vacancies.create(organisation: school)
    visit job_path(vacancy)
  end

  context "when the vacancy status is published" do
    let(:vacancy) { create(:vacancy, :published) }

    scenario "jobseekers can view the vacancy" do
      verify_vacancy_show_page_details(vacancy)
    end

    scenario "the page view is tracked" do
      expect { visit job_path(vacancy) }.to have_enqueued_job(PersistVacancyPageViewJob).with(vacancy.id)
    end

    context "when the publish_on date is in the future" do
      let(:vacancy) { create(:vacancy, :future_publish) }

      scenario "Job post with a future publish_on date are not accessible" do
        expect(page).to have_content("Page not found")
        expect(page).to_not have_content(vacancy.job_title)
      end
    end

    context "when the vacancy has expired" do
      let(:vacancy) { create(:vacancy, :expired) }

      scenario "it shows warnings that the post has expired" do
        expect(page).to have_content("EXPIRED")
        expect(page).to have_content("This job expired on #{vacancy.expires_at.to_date}")
      end
    end

    context "when the vacancy has not expired" do
      scenario "it does not show warnings that the post has expired" do
        expect(page).not_to have_content("EXPIRED")
        expect(page).not_to have_content("This job expired on #{vacancy.expires_at.to_date}")
      end
    end

    context "with multiple working patterns" do
      let(:vacancy) { create(:vacancy, working_patterns: %w[full_time part_time]) }

      scenario "the page contains correct JobPosting schema.org mark up" do
        expect(script_tag_content(wrapper_class: ".jobref"))
          .to eq(vacancy_json_ld(VacancyPresenter.new(vacancy)).to_json)
      end
    end

    context "with supporting documents attached" do
      scenario "can see the supporting documents section" do
        expect(page).to have_content(I18n.t("jobs.supporting_documents"))
        expect(page).to have_content("Test.png")
      end
    end

    context "when there is an application link set" do
      let(:vacancy) { create(:vacancy, :no_tv_applications) }

      scenario "a jobseeker can click on the application link" do
        click_on I18n.t("jobs.apply")

        expect(page.current_url).to eq vacancy.application_link
      end
    end

    context "meta tags" do
      include ActionView::Helpers::SanitizeHelper

      scenario "the vacancy's meta data are rendered correctly" do
        visit job_path(vacancy)

        expect(page.find('meta[name="description"]', visible: false)["content"])
          .to eq(strip_tags(vacancy.job_advert))
      end

      scenario "the vacancy's open graph meta data are rendered correctly" do
        visit job_path(vacancy)

        expect(page.find('meta[property="og:description"]', visible: false)["content"])
          .to eq(strip_tags(vacancy.job_advert))
      end
    end

    context "when creating a job alert" do
      let(:vacancy) { create(:vacancy, subjects: %w[Physics]) }

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
  end

  context "when the vacancy status is draft" do
    let(:vacancy) { create(:vacancy, :draft) }

    scenario "jobseekers cannot view the vacancy" do
      expect(page).to have_content("Page not found")
      expect(page).to_not have_content(vacancy.job_title)
    end
  end
end
