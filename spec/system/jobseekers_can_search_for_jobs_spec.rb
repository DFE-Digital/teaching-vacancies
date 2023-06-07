require "rails_helper"

RSpec.shared_examples "a successful search" do
  context "when searching for teacher jobs" do
    let(:keyword) { "Teacher" }

    it "adds the expected filters" do
      expect(page).to have_css("a", text: "Remove this filter Teacher")
    end

    it "displays page 1 jobs" do
      expect(page).to have_css(".search-results > .search-results__item", count: 2)
      expect(page).to have_content strip_tags(I18n.t("app.pagy_stats_html", from: 1, to: 2, total: 6, type: "results"))
    end

    context "when navigating between pages" do
      it "displays page 3 jobs" do
        within ".govuk-pagination" do
          click_on "3"
        end

        expect(page).to have_css(".search-results > .search-results__item", count: 2)
        expect(page).to have_content strip_tags(I18n.t("app.pagy_stats_html", from: 5, to: 6, total: 6, type: "results"))
      end
    end
  end

  context "when searching for maths jobs" do
    let(:per_page) { 100 }
    let(:keyword) { "Maths Teacher" }

    it "adds the expected filters" do
      expect(page).to have_css("a", text: "Remove this filter Teacher")
    end

    it "displays only the Maths jobs" do
      expect(page).to have_content strip_tags(I18n.t("app.pagy_stats_html", from: 1, to: 2, total: 2, type: "results"))
    end

    context "when sorting the jobs by most recently published" do
      it "displays the Maths jobs that were published most recently first" do
        expect("Maths 1").to appear_before("Maths Teacher 2")
      end
    end

    context "when sorting by most relevant" do
      before { click_on I18n.t("jobs.sort_by.most_relevant").humanize }

      it "lists the most relevant jobs first" do
        expect("Maths Teacher 2").to appear_before("Maths 1")
      end
    end

    context "when clearing all applied filters" do
      before { click_on I18n.t("shared.filter_group.clear_all_filters") }

      it "displays no remove filter links" do
        expect(page).to_not have_css("a", text: "Remove this filter Teacher")
      end
    end

    context "when removing a filter" do
      before { click_on "Remove this filter Teacher" }

      it "removes the filter" do
        expect(page).to_not have_css("a", text: "Remove this filter Teacher")
      end
    end
  end
end

RSpec.describe "Jobseekers can search for jobs on the jobs index page" do
  let(:academy_1) { create(:school) }
  let(:academy_2) { create(:school) }
  let(:free_school_1) { create(:school) }
  let(:free_school_2) { create(:school) }
  let(:local_authority_school_1) { create(:school, gias_data: { "EstablishmentTypeGroup (code)" => "4" }) }
  let(:local_authority_school_2) { create(:school, gias_data: { "EstablishmentTypeGroup (name)" => "Local authority maintained schools" }) }
  let(:school) { create(:school) }
  let!(:maths_job1) { create(:vacancy, :past_publish, :teacher, publish_on: Date.current - 1, job_title: "Maths 1", subjects: %w[Mathematics], organisations: [school], phases: %w[secondary]) }
  let!(:maths_job2) { create(:vacancy, :past_publish, :teacher, publish_on: Date.current - 2, job_title: "Maths Teacher 2", subjects: %w[Mathematics], organisations: [school], phases: %w[secondary]) }
  let!(:job1) { create(:vacancy, :past_publish, :teacher, job_title: "Physics Teacher", subjects: [], organisations: [academy_1]) }
  let!(:job2) { create(:vacancy, :past_publish, :teacher, job_title: "PE Teacher", subjects: [], organisations: [academy_2]) }
  let!(:job3) { create(:vacancy, :past_publish, :teacher, job_title: "Chemistry Teacher", subjects: [], organisations: [free_school_1]) }
  let!(:job4) { create(:vacancy, :past_publish, :teacher, job_title: "Geography Teacher", subjects: [], organisations: [free_school_2]) }
  let!(:expired_job) { create(:vacancy, :expired, :teacher, job_title: "Maths Teacher", subjects: [], organisations: [school]) }
  let(:per_page) { 2 }

  context "when searching using the mobile search fields" do
    before do
      stub_const("Pagy::DEFAULT", Pagy::DEFAULT.merge(items: per_page))
      visit jobs_path
      fill_in "Keyword", with: keyword
      click_on I18n.t("buttons.search")
    end

    it_behaves_like "a successful search"
  end

  context "when searching using the desktop search field" do
    before do
      stub_const("Pagy::DEFAULT", Pagy::DEFAULT.merge(items: per_page))
      visit jobs_path
      fill_in "Keyword", with: keyword
      click_on I18n.t("buttons.search")
    end

    it_behaves_like "a successful search"
  end

  context "jobseekers can use the organisation type filter to search for jobs" do
    let(:local_authority_school_1) { create(:school) }
    let(:local_authority_school_2) { create(:school) }
    let!(:job5) { create(:vacancy, :past_publish, :teacher, job_title: "History Teacher", subjects: [], organisations: [local_authority_school_1]) }
    let!(:job6) { create(:vacancy, :past_publish, :teacher, job_title: "Biology Teacher", subjects: [], organisations: [local_authority_school_2]) }

    before do
      academy_1.update(gias_data: academy_1.gias_data.merge!({ "EstablishmentTypeGroup (code)" => "10" }))
      academy_2.update(gias_data: academy_2.gias_data.merge!({ "EstablishmentTypeGroup (name)" => "Academies" }))
      free_school_1.update(gias_data: free_school_1.gias_data.merge!({ "EstablishmentTypeGroup (code)" => "11" }))
      free_school_2.update(gias_data: free_school_2.gias_data.merge!({ "EstablishmentTypeGroup (name)" => "Free Schools" }))
      local_authority_school_1.update(gias_data: local_authority_school_1.gias_data.merge!({ "EstablishmentTypeGroup (code)" => "4" }))
      local_authority_school_2.update(gias_data: local_authority_school_2.gias_data.merge!({ "EstablishmentTypeGroup (name)" => "Local authority maintained schools" }))
    end

    context "when academy is selected" do
      it "only shows vacancies from academies" do
        visit jobs_path
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.academy")
        click_on I18n.t("buttons.search")

        expect(page).to have_content(job1.job_title)
        expect(page).to have_content(job2.job_title)
        expect(page).to have_content(job3.job_title)
        expect(page).to have_content(job4.job_title)
        expect(page).not_to have_content(maths_job1.job_title)
        expect(page).not_to have_content(maths_job2.job_title)
        expect(page).not_to have_content(job5.job_title)
        expect(page).not_to have_content(job6.job_title)
      end
    end

    context "when local authority is selected" do
      it "only shows vacancies from local authorities" do
        visit jobs_path
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.local_authority")
        click_on I18n.t("buttons.search")

        expect(page).not_to have_content(job1.job_title)
        expect(page).not_to have_content(job2.job_title)
        expect(page).not_to have_content(job3.job_title)
        expect(page).not_to have_content(job4.job_title)
        expect(page).not_to have_content(maths_job1.job_title)
        expect(page).not_to have_content(maths_job2.job_title)
        expect(page).to have_content(job5.job_title)
        expect(page).to have_content(job6.job_title)
      end
    end

    context "when both local authority and academy are selected" do
      it "shows vacancies from both local authorities and academies" do
        visit jobs_path
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.academy")
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.local_authority")
        click_on I18n.t("buttons.search")

        expect(page).to have_content(job1.job_title)
        expect(page).to have_content(job2.job_title)
        expect(page).to have_content(job3.job_title)
        expect(page).to have_content(job4.job_title)
        expect(page).not_to have_content(maths_job1.job_title)
        expect(page).not_to have_content(maths_job2.job_title)
        expect(page).to have_content(job5.job_title)
        expect(page).to have_content(job6.job_title)
      end
    end
  end
end
