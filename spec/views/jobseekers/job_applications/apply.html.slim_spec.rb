require "rails_helper"

RSpec.describe "jobseekers/job_applications/apply" do
  let(:apply_view) { Capybara.string(rendered) }
  let(:jobseeker) { build_stubbed(:jobseeker) }
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:job_application) { build_stubbed(:job_application, :status_draft, jobseeker:, vacancy:) }
  let(:current_jobseeker) { jobseeker }
  let(:completed_steps) { [] }
  let(:all_steps) { [] }
  let(:form) { Jobseekers::JobApplication::PreSubmitForm.new(completed_steps:, all_steps:) }

  before do
    allow(view).to receive_messages(current_jobseeker:, vacancy:, job_application:)
    assign :job_application, job_application
    assign :form, form

    render
  end

  describe "banner" do
    subject(:banner) { apply_view.find(".review-banner") }

    let(:selectors) do
      {
        header: "h1",
        tag: ".status-tag",
        delete_btn: ".delete-application",
        withdraw_btn: ".withdraw-application",
        download_btn: ".print-application",
        view_link: ".view-listing-link",
      }
    end

    it "renders section" do
      expect(banner).to have_css(selectors[:header], text: "#{vacancy.job_title} at #{vacancy.organisation.name}")
      expect(banner).to have_css(selectors[:tag], text: "draft")

      expect(banner).to have_css(selectors[:view_link], text: "View this listing (opens in new tab)")
      expect(banner).to have_link("View this listing (opens in new tab)", href: job_path(vacancy))

      expect(banner).to have_css(selectors[:delete_btn])
      expect(banner).to have_link("Delete", href: jobseekers_job_application_confirm_destroy_path(job_application))

      expect(banner).to have_no_css(selectors[:download_btn])
      expect(banner).to have_no_css(selectors[:withdraw_btn])
    end
  end

  describe "task list" do
    subject(:tasks) { apply_view.all(".govuk-task-list__item") }

    context "when viewed by publisher" do
      let(:current_jobseeker) { nil }
      let(:expected_tasks) do
        [
          { name: "Personal details", status: "Incomplete" },
          { name: "Professional status", status: "Incomplete" },
          { name: "Qualifications", status: "Incomplete" },
          { name: "Training and continuing professional development (CPD)", status: "Incomplete" },
          { name: "Professional body memberships", status: "Incomplete" },
          { name: "Work history", status: "Incomplete" },
          { name: "Personal statement", status: "Incomplete" },
          { name: "References", status: "Incomplete" },
          { name: "Ask for support if you have a disability or other needs", status: "Incomplete" },
          { name: "Declarations", status: "Incomplete" },
        ]
      end

      it "renders a tasks list" do
        tasks.each.with_index do |task, index|
          expect(task.find(".govuk-task-list__name-and-hint a")).to have_text expected_tasks.dig(index, :name)
          expect(task.find(".govuk-task-list__status")).to have_text expected_tasks.dig(index, :status)
        end
      end
    end

    context "when viewed by jobseeker" do
      let(:expected_tasks) do
        [
          { name: "Personal details", status: "Incomplete" },
          { name: "Professional status", status: "Incomplete" },
          { name: "Qualifications", status: "Incomplete" },
          { name: "Training and continuing professional development (CPD)", status: "Incomplete" },
          { name: "Professional body memberships", status: "Incomplete" },
          { name: "Work history", status: "Incomplete" },
          { name: "Personal statement", status: "Incomplete" },
          { name: "References", status: "Incomplete" },
          { name: "Equal opportunities and recruitment monitoring", status: "Incomplete" },
          { name: "Ask for support if you have a disability or other needs", status: "Incomplete" },
          { name: "Declarations", status: "Incomplete" },
        ]
      end

      it "renders a tasks list" do
        tasks.each.with_index do |task, index|
          expect(task.find(".govuk-task-list__name-and-hint a")).to have_text expected_tasks.dig(index, :name)
          expect(task.find(".govuk-task-list__status")).to have_text expected_tasks.dig(index, :status)
        end
      end
    end

    context "when catholic vacancy" do
      let(:vacancy) { build_stubbed(:vacancy, :catholic) }
      let(:expected_tasks) do
        [
          { name: "Personal details", status: "Incomplete" },
          { name: "Professional status", status: "Incomplete" },
          { name: "Qualifications", status: "Incomplete" },
          { name: "Training and continuing professional development (CPD)", status: "Incomplete" },
          { name: "Professional body memberships", status: "Incomplete" },
          { name: "Work history", status: "Incomplete" },
          { name: "Personal statement", status: "Incomplete" },
          { name: "Religious information", status: "Incomplete" },
          { name: "References", status: "Incomplete" },
          { name: "Equal opportunities and recruitment monitoring", status: "Incomplete" },
          { name: "Ask for support if you have a disability or other needs", status: "Incomplete" },
          { name: "Declarations", status: "Incomplete" },
        ]
      end

      it "renders a tasks list" do
        tasks.each.with_index do |task, index|
          expect(task.find(".govuk-task-list__name-and-hint a")).to have_text expected_tasks.dig(index, :name)
          expect(task.find(".govuk-task-list__status")).to have_text expected_tasks.dig(index, :status)
        end
      end
    end

    context "when other religion vacancy" do
      let(:vacancy) { build_stubbed(:vacancy, :other_religion) }
      let(:expected_tasks) do
        [
          { name: "Personal details", status: "Incomplete" },
          { name: "Professional status", status: "Incomplete" },
          { name: "Qualifications", status: "Incomplete" },
          { name: "Training and continuing professional development (CPD)", status: "Incomplete" },
          { name: "Professional body memberships", status: "Incomplete" },
          { name: "Work history", status: "Incomplete" },
          { name: "Personal statement", status: "Incomplete" },
          { name: "Religious information", status: "Incomplete" },
          { name: "References", status: "Incomplete" },
          { name: "Equal opportunities and recruitment monitoring", status: "Incomplete" },
          { name: "Ask for support if you have a disability or other needs", status: "Incomplete" },
          { name: "Declarations", status: "Incomplete" },
        ]
      end

      it "renders a tasks list" do
        tasks.each.with_index do |task, index|
          expect(task.find(".govuk-task-list__name-and-hint a")).to have_text expected_tasks.dig(index, :name)
          expect(task.find(".govuk-task-list__status")).to have_text expected_tasks.dig(index, :status)
        end
      end
    end
  end
end
