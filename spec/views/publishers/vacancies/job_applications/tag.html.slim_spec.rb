require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/tag" do
  let(:form) { Publishers::JobApplication::TagForm.new(job_applications:, status:, origin:) }
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:job_applications) { build_stubbed_list(:job_application, 3, :status_submitted, vacancy:) }
  let(:status) { nil }
  let(:origin) { "submitted" }
  let(:tag_page) { Capybara.string(rendered) }

  before do
    assign :form, form
    without_partial_double_verification do
      allow(view).to receive(:vacancy).and_return(vacancy)
    end
    render
  end

  describe "header" do
    context "when there is one job application" do
      let(:job_applications) { build_stubbed_list(:job_application, 1, :status_submitted, vacancy:) }

      it "renders header with name" do
        expect(tag_page.find("h1")).to have_text(I18n.t("publishers.vacancies.job_applications.tag.what_application_status.one"))
      end
    end

    context "when there are many job applications" do
      let(:li_tags) { tag_page.all("li") }

      it "renders header without name" do
        expect(tag_page.find("h1")).to have_text(I18n.t("publishers.vacancies.job_applications.tag.what_application_status.other"))
      end

      it "lists candidates" do
        expect(li_tags.count).to eq(job_applications.count)
        li_tags.each.with_index do |li_tag, idx|
          expect(li_tag).to have_text(job_applications[idx].name)
        end
      end
    end
  end

  describe "form status options" do
    context "when job applications have status submitted" do
      let(:origin) { "submitted" }
      let(:job_applications) { build_stubbed_list(:job_application, 3, :status_submitted, vacancy:) }

      %i[unsuccessful shortlisted interviewing offered].each do |status|
        it "shows a radio button for status '#{status}'" do
          expect(rendered).to have_css("#publishers-job-application-tag-form-status-#{status}-field")
        end
      end
    end

    context "when job applications have status shortlisted" do
      let(:origin) { "shortlisted" }
      let(:job_applications) { build_stubbed_list(:job_application, 3, :status_shortlisted, vacancy:) }

      %i[unsuccessful interviewing offered].each do |status|
        it "shows a radio button for status '#{status}'" do
          expect(rendered).to have_css("#publishers-job-application-tag-form-status-#{status}-field")
        end
      end
    end

    context "when job applications have status interviewing" do
      let(:origin) { "interviewing" }
      let(:job_applications) { build_stubbed_list(:job_application, 3, :status_interviewing, vacancy:) }

      %i[unsuccessful-interview offered].each do |status|
        it "shows a radio button for status '#{status}'" do
          expect(rendered).to have_css("#publishers-job-application-tag-form-status-#{status}-field")
        end
      end
    end
  end
end
