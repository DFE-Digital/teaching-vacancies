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
  let(:academy1) { create(:school, school_type: "Academies") }
  let(:academy2) { create(:school, school_type: "Academy") }
  let(:free_school1) { create(:school, school_type: "Free schools") }
  let(:free_school2) { create(:school, school_type: "Free school") }
  let(:local_authority_school1) { create(:school, school_type: "Local authority maintained schools") }
  let(:local_authority_school2) { create(:school, school_type: "Local authority maintained schools") }
  let(:school) { create(:school) }

  let!(:maths_job1) { create(:vacancy, :past_publish, :no_tv_applications, :teacher, publish_on: Date.current - 1, job_title: "Maths 1", subjects: %w[Mathematics], organisations: [school], phases: %w[secondary], expires_at: Date.current + 1, geolocation: "POINT(-0.019501 51.504949)") }
  let!(:maths_job2) { create(:vacancy, :past_publish, :no_tv_applications, :teacher, publish_on: Date.current - 2, job_title: "Maths Teacher 2", subjects: %w[Mathematics], organisations: [school], phases: %w[secondary], expires_at: Date.current + 3, geolocation: "POINT(-2.2374 53.4810)") }
  let!(:job1) { create(:vacancy, :past_publish, :no_tv_applications, :teacher, job_title: "Physics Teacher", subjects: ["Physics"], organisations: [academy1], phases: %w[secondary], expires_at: Date.current + 2) }
  let!(:job2) { create(:vacancy, :past_publish, :no_tv_applications, :teacher, job_title: "PE Teacher", subjects: [], organisations: [academy2], expires_at: Date.current + 5) }
  let!(:job3) { create(:vacancy, :past_publish, :no_tv_applications, :teacher, job_title: "Chemistry Teacher", subjects: [], organisations: [free_school1], expires_at: Date.current + 4) }
  let!(:job4) { create(:vacancy, :past_publish, :no_tv_applications, :teacher, job_title: "Geography Teacher", subjects: [], publisher_organisation: free_school1, organisations: [free_school1, free_school2], expires_at: Date.current + 6) }
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

  context "jobseekers can use the quick apply type filter to search for jobs" do
    let!(:quick_apply_job) { create(:vacancy, job_title: "Quick Apply Job", organisations: [school], enable_job_applications: true) }

    context "when quick apply is selected" do
      it "only shows vacancies that are quick apply" do
        visit jobs_path
        check I18n.t("helpers.label.publishers_job_listing_applying_for_the_job_form.quick_apply")
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([quick_apply_job])
        expect_page_not_to_show_jobs([job1, job2, job3, job4, maths_job1, maths_job2])
      end
    end
  end

  context "jobseekers can sort jobs by closing date" do
    it "lists the jobs with the earliest closing date first" do
      visit jobs_path
      select "Closing date", :from => "sort-by-field"
      click_button "Sort"
      expect("Maths 1").to appear_before("Physics Teacher")
      expect("Physics Teacher").to appear_before("Maths Teacher 2")
      expect("Maths Teacher 2").to appear_before("Chemistry Teacher")
      expect("Chemistry Teacher").to appear_before("PE Teacher")
      expect("PE Teacher").to appear_before("Geography Teacher")
    end
  end

  context "when jobseekers search without entering a location" do
    it "does not show any measure of distance" do
      visit jobs_path
      fill_in "Keyword", with: "teacher"
      click_on I18n.t("buttons.search")
      expect(page).not_to have_content "Distance from location"
    end
  end

  context "when jobseekers search after entering a location" do
    it "shows distance between school and their location" do
      visit jobs_path
      fill_in 'location-field', with: 'Birmingham'
      select "200 miles", from: "radius-field"
      click_on I18n.t("buttons.search")

      within('.search-results__item', text: 'Maths 1') do
        distance_text = find('dt', text: 'Distance from location').sibling('dd').text
        expect(distance_text).to eq('81 miles')
      end
      
      within('.search-results__item', text: 'Maths Teacher 2') do
        distance_text = find('dt', text: 'Distance from location').sibling('dd').text
        expect(distance_text).to eq('160 miles')
      end
    end
  end

  context "jobseekers can use the organisation type filter to search for jobs" do
    let!(:job5) { create(:vacancy, :past_publish, :teacher, job_title: "History Teacher", subjects: [], publisher_organisation: local_authority_school1, organisations: [local_authority_school1, local_authority_school2]) }

    context "when academy is selected" do
      it "only shows vacancies from academies" do
        visit jobs_path
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.academy")
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([job1, job2, job3, job4])
        expect_page_not_to_show_jobs([maths_job1, maths_job2, job5])
      end
    end

    context "when local authority is selected" do
      it "only shows vacancies from local authorities" do
        visit jobs_path
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.local_authority")
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([job5])
        expect_page_not_to_show_jobs([job1, job2, job3, job4, maths_job1, maths_job2])
      end
    end

    context "when both local authority and academy are selected" do
      it "shows vacancies from both local authorities and academies" do
        visit jobs_path
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.academy")
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.local_authority")
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([job1, job2, job3, job4, job5])
        expect_page_not_to_show_jobs([maths_job1, maths_job2])
      end
    end

    context "when used in conjunction with a search term" do
      # testing this unusual edge case around removing auto-populated search terms because it was raising exceptions for us in the past.
      it "returns the correct vacancies even after removing auto-populated search terms" do
        visit jobs_path
        fill_in "Keyword", with: "Physics teacher"
        check "Academy"

        click_on I18n.t("buttons.search")

        click_link "Remove this filter Teacher"
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([job1])
        expect_page_not_to_show_jobs([job2, job3, job4, job5, maths_job1, maths_job2])
      end
    end
  end

  context "when filtering by school type" do
    let(:special_school1) { create(:school, name: "Community special school", detailed_school_type: "Community special school") }
    let(:special_school2) { create(:school, name: "Foundation special school", detailed_school_type: "Foundation special school") }
    let(:special_school3) { create(:school, name: "Non-maintained special school", detailed_school_type: "Non-maintained special school") }
    let(:special_school4) { create(:school, name: "Academy special converter", detailed_school_type: "Academy special converter") }
    let(:special_school5) { create(:school, name: "Academy special sponsor led", detailed_school_type: "Academy special sponsor led") }
    let(:special_school6) { create(:school, name: "Non-maintained special school", detailed_school_type: "Free schools special") }
    let(:faith_school) { create(:school, name: "Religious", gias_data: { "ReligiousCharacter (name)" => "anything" }) }
    let(:faith_school2) { create(:school, name: "ABCDEF", gias_data: { "ReligiousCharacter (name)" => "somethingelse" }) }
    let(:non_faith_school1) { create(:school, name: "nonfaith1", gias_data: { "ReligiousCharacter (name)" => "" }) }
    let(:non_faith_school2) { create(:school, name: "nonfaith2", gias_data: { "ReligiousCharacter (name)" => "Does not apply" }) }
    let(:non_faith_school3) { create(:school, name: "nonfaith3", gias_data: { "ReligiousCharacter (name)" => "None" }) }

    let!(:special_job1) { create(:vacancy, :past_publish, :teacher, job_title: "AAAA", subjects: [], organisations: [special_school1]) }
    let!(:special_job2) { create(:vacancy, :past_publish, :teacher, job_title: "BBBB", subjects: [], organisations: [special_school2]) }
    let!(:special_job3) { create(:vacancy, :past_publish, :teacher, job_title: "CCCC", subjects: [], organisations: [special_school3]) }
    let!(:special_job4) { create(:vacancy, :past_publish, :teacher, job_title: "DDDD", subjects: [], organisations: [special_school4]) }
    let!(:special_job5) { create(:vacancy, :past_publish, :teacher, job_title: "EEEE", subjects: [], organisations: [special_school5]) }
    let!(:special_job6) { create(:vacancy, :past_publish, :teacher, job_title: "FFFF", subjects: [], organisations: [special_school6]) }
    let!(:faith_job) { create(:vacancy, :past_publish, :teacher, job_title: "religious", subjects: ["Physics"], publisher_organisation: faith_school, organisations: [faith_school, faith_school2], phases: %w[secondary]) }
    let!(:non_faith_job1) { create(:vacancy, :past_publish, :teacher, job_title: "nonfaith1", subjects: [], organisations: [non_faith_school1]) }
    let!(:non_faith_job2) { create(:vacancy, :past_publish, :teacher, job_title: "nonfaith2", subjects: [], organisations: [non_faith_school2]) }
    let!(:non_faith_job3) { create(:vacancy, :past_publish, :teacher, job_title: "nonfaith3", subjects: [], organisations: [non_faith_school3]) }

    it "allows user to filter by special schools" do
      visit jobs_path
      check I18n.t("organisations.filters.special_school")
      click_on I18n.t("buttons.search")

      expect_page_to_show_jobs([special_job1, special_job2, special_job3, special_job4, special_job5, special_job6])
      expect_page_not_to_show_jobs([job1, job2, job3, job4, maths_job1, maths_job2, faith_job, non_faith_job1, non_faith_job2, non_faith_job3])
    end

    it "allows user to filter by faith schools" do
      visit jobs_path
      check I18n.t("organisations.filters.faith_school")
      click_on I18n.t("buttons.search")

      expect_page_to_show_jobs([faith_job])
      expect_page_not_to_show_jobs([special_job1, special_job2, special_job3, special_job4, special_job5, special_job6, job1, job2, job3, job4, maths_job1, maths_job2, non_faith_job1, non_faith_job2, non_faith_job3])
    end

    it "allows users to filter by both faith and special schools" do
      visit jobs_path
      check I18n.t("organisations.filters.faith_school")
      check I18n.t("organisations.filters.special_school")
      click_on I18n.t("buttons.search")

      expect_page_to_show_jobs([special_job1, special_job2, special_job3, special_job4, special_job5, special_job6, faith_job])
      expect_page_not_to_show_jobs([job1, job2, job3, job4, maths_job1, maths_job2])
    end

    context "when used in conjunction with a search term" do
      # testing this unusual edge case around removing auto-populated search terms because it was raising exceptions for us in the past.
      it "returns the correct vacancies even after removing auto-populated search terms" do
        visit jobs_path
        fill_in "Keyword", with: "Physics teacher"
        check I18n.t("organisations.filters.faith_school")

        click_on I18n.t("buttons.search")

        click_link "Remove this filter Teacher"
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([faith_job])
        expect_page_not_to_show_jobs([job1, job2, job3, job4, maths_job1, maths_job2, special_job1, special_job2, special_job3, special_job4, special_job5, special_job6])
      end
    end
  end

  def expect_page_to_show_jobs(jobs)
    jobs.each do |job|
      expect(page).to have_link(job.job_title, count: 1)
    end
  end

  def expect_page_not_to_show_jobs(jobs)
    jobs.each do |job|
      expect(page).not_to have_link job.job_title
    end
  end
end
