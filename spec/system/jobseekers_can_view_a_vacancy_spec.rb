require "rails_helper"

RSpec.describe "Viewing a single published vacancy" do
  let(:school_group) { create(:local_authority) }
  let(:school1) { create(:school) }
  let(:school2) { create(:school) }
  let(:vacancy) do
    create(:vacancy, vacancy_trait, :at_multiple_schools, :with_supporting_documents, :no_tv_applications,
           organisation_vacancies_attributes: [
             { organisation: school1 }, { organisation: school2 }
           ],
           working_patterns: %w[full_time part_time],
           subjects: %w[Physics])
  end

  before do
    SchoolGroupMembership.find_or_create_by(school_id: school1.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school2.id, school_group_id: school_group.id)
    vacancy.reload
    visit job_path(vacancy)
  end

  context "when the vacancy status is published" do
    let(:vacancy_trait) { :published }

    scenario "jobseekers can view the vacancy" do
      verify_vacancy_show_page_details(vacancy)
    end

    context "when the publish_on date is in the future" do
      let(:vacancy_trait) { :future_publish }

      scenario "Job post with a future publish_on date are not accessible" do
        expect(page).to have_content("Page not found")
        expect(page).to_not have_content(vacancy.job_title)
      end
    end

    context "when the vacancy has expired" do
      let(:vacancy_trait) { :expired }

      scenario "it shows warnings that the post has expired" do
        expect(page).to have_content("EXPIRED")
        expect(page).to have_content("This job expired on #{format_date(vacancy.expires_at, :date_only)}")
      end
    end

    context "when the vacancy has not expired" do
      scenario "it does not show warnings that the post has expired" do
        expect(page).not_to have_content("EXPIRED")
        expect(page).not_to have_content("This job expired on #{format_date(vacancy.expires_at, :date_only)}")
      end
    end

    context "with multiple working patterns" do
      scenario "the page contains correct JobPosting schema.org mark up" do
        expect(script_tag_content(wrapper_class: ".jobref"))
          .to eq(vacancy_json_ld(VacancyPresenter.new(vacancy)).to_json)
      end
    end

    context "with supporting documents attached" do
      scenario "can see the supporting documents section" do
        expect(page).to have_content(I18n.t("jobs.supporting_documents"))
        expect(page).to have_content(vacancy.supporting_documents.first.filename)
      end
    end

    context "when there is an application link set" do
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
      scenario "can click on the first link to create a job alert" do
        click_on I18n.t("jobs.alert.similar.terse")
        expect(page).to have_content(I18n.t("subscriptions.new.title"))
        expect(page.find_field("jobseekers-subscription-form-keyword-field").value).to eq("Physics")
        expect(page.find_field("jobseekers-subscription-form-location-field").value).to eq(Geocoder::DEFAULT_LOCATION)
        expect(page.find_field("jobseekers-subscription-form-radius-field").value).to eq("10")
      end

      scenario "can click on the second link to create a job alert" do
        click_on I18n.t("jobs.alert.similar.verbose.link_text")
        expect(page).to have_content(I18n.t("subscriptions.new.title"))
        expect(page.find_field("jobseekers-subscription-form-keyword-field").value).to eq("Physics")
        expect(page.find_field("jobseekers-subscription-form-location-field").value).to eq(Geocoder::DEFAULT_LOCATION)
        expect(page.find_field("jobseekers-subscription-form-radius-field").value).to eq("10")
      end
    end
  end

  context "when the vacancy status is draft" do
    let(:vacancy_trait) { :draft }

    scenario "jobseekers cannot view the vacancy" do
      expect(page).to have_content("Page not found")
      expect(page).to_not have_content(vacancy.job_title)
    end
  end
end
